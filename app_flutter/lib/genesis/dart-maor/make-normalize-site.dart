// 🔌 חוט-מפעל · make-normalize-site — חיטוי תוכן-האתר-הציבורי: allowlist מלא + תקרות.
//  הקונפיג מסתנכרן לענן/גיבוי ⇒ כל שדה זר נזרק; קישורים https-בלבד; טקסטים מגוזמים.
//  חסר/לא-אובייקט ⇒ null (=undefined ב-JS — אין אתר-ציבורי, ביט-זהה).
//  מוצא: maor/src/lib/config.ts:216-512 כלשונו (עוזרי-הקובץ הפרטיים siteStr/normLocalized/
//  sitePosNum/sitePhone נכללו); safeHttpsUrl ו-SITE_LANGS הוזרקו כשקעי-מפעל (חוק-1).
//  אפס-import (dart-core בלבד). התנהגות זהה-לחלוטין למקור-ה-JS (חוק-4).
//
//  @param safeHttpsUrl שקע: (raw)=>String?  ·  @param SITE_LANGS שקע: List<String>

// ניקוי תווי-בקרה (Unicode Cc: U+0000..U+001F, U+007F..U+009F) — מקביל ל-/\p{Cc}/gu.
String _stripCc(String s) {
  final sb = StringBuffer();
  for (final r in s.runes) {
    if ((r >= 0x00 && r <= 0x1F) || (r >= 0x7F && r <= 0x9F)) continue;
    sb.writeCharCode(r);
  }
  return sb.toString();
}

// slice(0, max) של JS — לפי code-units של UTF-16 (זהה ל-String.substring של Dart).
String _slice(String s, int max) => s.length <= max ? s : s.substring(0, max);

final RegExp _phoneStrip = RegExp(r'[^\d+()\-\s]');

Map<String, dynamic>? Function(dynamic) makeNormalizeSite(
    String? Function(dynamic) safeHttpsUrl, List<String> SITE_LANGS) {
  String siteStr(dynamic v, int max) {
    if (v is String) return _slice(_stripCc(v).trim(), max);
    return '';
  }

  // טקסט רב-לשוני: מחרוזת ⇒ מגוזמת; מפה ⇒ רק שפות-allowlist עם ערך לא-ריק; אחרת null.
  dynamic normLocalized(dynamic v, int max) {
    if (v is String) {
      final s = siteStr(v, max);
      return s.isEmpty ? null : s;
    }
    if (v is Map) {
      final out = <String, String>{};
      for (final l in SITE_LANGS) {
        final s = siteStr(v[l], max);
        if (s.isNotEmpty) out[l] = s;
      }
      return out.isNotEmpty ? out : null;
    }
    return null;
  }

  // מספר חיובי-סופי או null.
  num? sitePosNum(dynamic v) {
    if (v is num && v.isFinite && v >= 0) return v;
    return null;
  }

  // טלפון לתצוגה/חיוג — ספרות +()- ורווח בלבד, עד 24.
  String sitePhone(dynamic v) {
    if (v is String) return _slice(v.replaceAll(_phoneStrip, '').trim(), 24);
    return '';
  }

  Map<String, dynamic>? normalizeSite(dynamic raw) {
    if (raw is! Map) return null;
    final s = raw;
    final out = <String, dynamic>{};

    if (s['enabled'] == false) {
      out['enabled'] = false;
    } else if (s['enabled'] == true) {
      out['enabled'] = true;
    }

    final icon = siteStr(s['icon'], 12);
    if (icon.isNotEmpty) out['icon'] = icon;

    if (s['langs'] is List) {
      final seen = <dynamic>{};
      final langs = <dynamic>[];
      for (final l in (s['langs'] as List)) {
        if (SITE_LANGS.contains(l) && !seen.contains(l)) {
          seen.add(l);
          langs.add(l);
        }
      }
      if (langs.isNotEmpty) out['langs'] = langs;
    }

    final tagline = normLocalized(s['tagline'], 200);
    if (tagline != null) out['tagline'] = tagline;

    if (s['heroWords'] is List) {
      final words = (s['heroWords'] as List)
          .map((w) => normLocalized(w, 60))
          .where((w) => w != null)
          .take(8)
          .toList();
      if (words.isNotEmpty) out['heroWords'] = words;
    }

    if (s['stats'] is List) {
      final stats = (s['stats'] as List).map((st) {
        if (st is! Map) return null;
        final value = siteStr(st['value'], 24);
        final label = normLocalized(st['label'], 60);
        return (value.isNotEmpty && label != null)
            ? {'value': value, 'label': label}
            : null;
      }).where((x) => x != null).take(8).toList();
      if (stats.isNotEmpty) out['stats'] = stats;
    }

    if (s['liveFamilies'] == true) out['liveFamilies'] = true;
    final lfl = normLocalized(s['liveFamiliesLabel'], 60);
    if (lfl != null) out['liveFamiliesLabel'] = lfl;

    if (s['campaign'] is Map) {
      final c = s['campaign'] as Map;
      final camp = <String, dynamic>{};
      final ct = normLocalized(c['title'], 120);
      if (ct != null) camp['title'] = ct;
      final goal = sitePosNum(c['goal']);
      if (goal != null) camp['goal'] = goal;
      final raised = sitePosNum(c['raised']);
      if (raised != null) camp['raised'] = raised;
      final end = siteStr(c['end'], 30);
      if (end.isNotEmpty) camp['end'] = end;
      final cur = siteStr(c['currency'], 4);
      if (cur.isNotEmpty) camp['currency'] = cur;
      if (camp.isNotEmpty) out['campaign'] = camp;
    }

    if (s['services'] is List) {
      final svcs = (s['services'] as List).map((sv) {
        if (sv is! Map) return null;
        final title = normLocalized(sv['title'], 80);
        if (title == null) return null;
        final svc = <String, dynamic>{'title': title};
        final icon = siteStr(sv['icon'], 12);
        if (icon.isNotEmpty) svc['icon'] = icon;
        final text = normLocalized(sv['text'], 240);
        if (text != null) svc['text'] = text;
        return svc;
      }).where((x) => x != null).take(12).toList();
      if (svcs.isNotEmpty) out['services'] = svcs;
    }

    final news = normLocalized(s['news'], 800);
    if (news != null) out['news'] = news;
    final story = normLocalized(s['story'], 2000);
    if (story != null) out['story'] = story;

    if (s['gallery'] is List) {
      final imgs = (s['gallery'] as List)
          .map((g) => g is String ? safeHttpsUrl(g) : null)
          .where((g) => g != null)
          .take(24)
          .toList();
      if (imgs.isNotEmpty) out['gallery'] = imgs;
    }

    if (s['contact'] is Map) {
      final c = s['contact'] as Map;
      final contact = <String, dynamic>{};
      if (c['phones'] is List) {
        final phones = (c['phones'] as List)
            .map((p) => sitePhone(p))
            .where((p) => p.isNotEmpty)
            .take(8)
            .toList();
        if (phones.isNotEmpty) contact['phones'] = phones;
      }
      final wa = sitePhone(c['whatsapp']);
      if (wa.isNotEmpty) contact['whatsapp'] = wa;
      final email = siteStr(c['email'], 120);
      if (email.isNotEmpty && email.contains('@')) contact['email'] = email;
      final addr = normLocalized(c['address'], 200);
      if (addr != null) contact['address'] = addr;
      final hours = normLocalized(c['hours'], 120);
      if (hours != null) contact['hours'] = hours;
      final taxNote = normLocalized(c['taxNote'], 200);
      if (taxNote != null) contact['taxNote'] = taxNote;
      if (c['mapUrl'] is String) {
        final mu = safeHttpsUrl(c['mapUrl']);
        if (mu != null) contact['mapUrl'] = mu;
      }
      if (contact.isNotEmpty) out['contact'] = contact;
    }

    if (s['donateUrl'] is String) {
      final u = safeHttpsUrl(s['donateUrl']);
      if (u != null) out['donateUrl'] = u;
    }

    // ── עיצוב-דף-התרומות: שדות חדשים (allowlist + תקרות) ──
    String? imgUrl(dynamic v) => v is String ? safeHttpsUrl(v) : null;
    void setLT(String k, dynamic v, int max) {
      final t = normLocalized(v, max);
      if (t != null) out[k] = t;
    }

    final hi = imgUrl(s['heroImage']);
    if (hi != null) out['heroImage'] = hi;
    setLT('heroTitle', s['heroTitle'], 80);
    setLT('brandLine', s['brandLine'], 60);
    setLT('heroBadge', s['heroBadge'], 80);
    setLT('titleAccent', s['titleAccent'], 60);
    setLT('servicesHeading', s['servicesHeading'], 80);
    setLT('microCopy', s['microCopy'], 120);
    setLT('ticker', s['ticker'], 160);
    setLT('storyTitle', s['storyTitle'], 120);
    setLT('storyTitleAccent', s['storyTitleAccent'], 80);
    setLT('storyBadge', s['storyBadge'], 80);
    setLT('donateNote', s['donateNote'], 240);

    if (s['marquee'] is List) {
      final mq = (s['marquee'] as List)
          .map((m) => normLocalized(m, 80))
          .where((m) => m != null)
          .take(16)
          .toList();
      if (mq.isNotEmpty) out['marquee'] = mq;
    }

    if (s['calc'] is Map) {
      final c = s['calc'] as Map;
      final calc = <String, dynamic>{};
      final amt = sitePosNum(c['unitAmount']);
      if (amt != null) calc['unitAmount'] = amt;
      final unit = normLocalized(c['unit'], 60);
      if (unit != null) calc['unit'] = unit;
      final note = normLocalized(c['note'], 120);
      if (note != null) calc['note'] = note;
      if (calc.isNotEmpty) out['calc'] = calc;
    }

    if (s['tiers'] is List) {
      final tiers = (s['tiers'] as List).map((tr) {
        if (tr is! Map) return null;
        final name = normLocalized(tr['name'], 60);
        if (name == null) return null;
        final t = <String, dynamic>{'name': name};
        final amt = sitePosNum(tr['amount']);
        if (amt != null) t['amount'] = amt;
        final period = normLocalized(tr['period'], 40);
        if (period != null) t['period'] = period;
        if (tr['perks'] is List) {
          final perks = (tr['perks'] as List)
              .map((p) => normLocalized(p, 100))
              .where((p) => p != null)
              .take(8)
              .toList();
          if (perks.isNotEmpty) t['perks'] = perks;
        }
        if (tr['featured'] == true) t['featured'] = true;
        final url = imgUrl(tr['url']);
        if (url != null) t['url'] = url;
        return t;
      }).where((x) => x != null).take(6).toList();
      if (tiers.isNotEmpty) out['tiers'] = tiers;
    }

    if (s['testimonials'] is List) {
      final items = (s['testimonials'] as List).map((tt) {
        if (tt is! Map) return null;
        final quote = normLocalized(tt['quote'], 400);
        if (quote == null) return null;
        final t = <String, dynamic>{'quote': quote};
        final author = siteStr(tt['author'], 80);
        if (author.isNotEmpty) t['author'] = author;
        final role = normLocalized(tt['role'], 80);
        if (role != null) t['role'] = role;
        return t;
      }).where((x) => x != null).take(12).toList();
      if (items.isNotEmpty) out['testimonials'] = items;
    }

    if (s['faq'] is List) {
      final items = (s['faq'] as List).map((f) {
        if (f is! Map) return null;
        final q = normLocalized(f['q'], 200);
        final a = normLocalized(f['a'], 800);
        return (q != null && a != null) ? {'q': q, 'a': a} : null;
      }).where((x) => x != null).take(20).toList();
      if (items.isNotEmpty) out['faq'] = items;
    }

    if (s['events'] is List) {
      final items = (s['events'] as List).map((e) {
        if (e is! Map) return null;
        final title = normLocalized(e['title'], 120);
        if (title == null) return null;
        final ev = <String, dynamic>{'title': title};
        final date = siteStr(e['date'], 30);
        if (date.isNotEmpty) ev['date'] = date;
        final meta = normLocalized(e['meta'], 120);
        if (meta != null) ev['meta'] = meta;
        final url = imgUrl(e['url']);
        if (url != null) ev['url'] = url;
        return ev;
      }).where((x) => x != null).take(12).toList();
      if (items.isNotEmpty) out['events'] = items;
    }

    if (s['partners'] is List) {
      final items = (s['partners'] as List).map((p) {
        if (p is! Map) return null;
        final name = siteStr(p['name'], 80);
        if (name.isEmpty) return null;
        final pt = <String, dynamic>{'name': name};
        final logo = imgUrl(p['logo']);
        if (logo != null) pt['logo'] = logo;
        final url = imgUrl(p['url']);
        if (url != null) pt['url'] = url;
        return pt;
      }).where((x) => x != null).take(24).toList();
      if (items.isNotEmpty) out['partners'] = items;
    }

    if (s['transparency'] is Map) {
      final o = s['transparency'] as Map;
      final tr = <String, dynamic>{};
      final heading = normLocalized(o['heading'], 120);
      if (heading != null) tr['heading'] = heading;
      final text = normLocalized(o['text'], 600);
      if (text != null) tr['text'] = text;
      final url = imgUrl(o['reportsUrl']);
      if (url != null) tr['reportsUrl'] = url;
      if (o['badges'] is List) {
        final badges = (o['badges'] as List)
            .map((b) => normLocalized(b, 60))
            .where((b) => b != null)
            .take(6)
            .toList();
        if (badges.isNotEmpty) tr['badges'] = badges;
      }
      if (tr.isNotEmpty) out['transparency'] = tr;
    }

    // ── סיפור: מייסד/ת + ציר-זמן ──
    if (s['founder'] is Map) {
      final o = s['founder'] as Map;
      final f = <String, dynamic>{};
      final name = normLocalized(o['name'], 80);
      if (name != null) f['name'] = name;
      final quote = normLocalized(o['quote'], 200);
      if (quote != null) f['quote'] = quote;
      final photo = imgUrl(o['photo']);
      if (photo != null) f['photo'] = photo;
      if (f.isNotEmpty) out['founder'] = f;
    }

    if (s['timeline'] is List) {
      final items = (s['timeline'] as List).map((m) {
        if (m is! Map) return null;
        final year = siteStr(m['year'], 12);
        final title = normLocalized(m['title'], 120);
        if (year.isEmpty || title == null) return null;
        final it = <String, dynamic>{'year': year, 'title': title};
        final note = normLocalized(m['note'], 160);
        if (note != null) it['note'] = note;
        return it;
      }).where((x) => x != null).take(10).toList();
      if (items.isNotEmpty) out['timeline'] = items;
    }

    if (s['growth'] is Map) {
      final o = s['growth'] as Map;
      final g = <String, dynamic>{};
      final label = normLocalized(o['label'], 120);
      if (label != null) g['label'] = label;
      final delta = siteStr(o['delta'], 40);
      if (delta.isNotEmpty) g['delta'] = delta;
      if (o['points'] is List) {
        final pts = (o['points'] as List)
            .map((p) => (p is num && p.isFinite) ? p.clamp(0, 1) : null)
            .where((p) => p != null)
            .take(40)
            .toList();
        if (pts.length >= 2) g['points'] = pts;
      }
      if (g.isNotEmpty) out['growth'] = g;
    }

    if (s['paymentMethods'] is List) {
      final items = (s['paymentMethods'] as List).map((p) {
        if (p is! Map) return null;
        final label = normLocalized(p['label'], 60);
        final detail = normLocalized(p['detail'], 200);
        if (label == null || detail == null) return null;
        final pm = <String, dynamic>{'label': label, 'detail': detail};
        if (p['ltr'] == true) pm['ltr'] = true;
        return pm;
      }).where((x) => x != null).take(6).toList();
      if (items.isNotEmpty) out['paymentMethods'] = items;
    }

    if (s['contactForm'] is Map) {
      final o = s['contactForm'] as Map;
      final cf = <String, dynamic>{};
      if (o['enabled'] == true) {
        cf['enabled'] = true;
      } else if (o['enabled'] == false) {
        cf['enabled'] = false;
      }
      final note = normLocalized(o['note'], 200);
      if (note != null) cf['note'] = note;
      if (cf.isNotEmpty) out['contactForm'] = cf;
    }

    return out.isNotEmpty ? out : null;
  }

  return normalizeSite;
}
