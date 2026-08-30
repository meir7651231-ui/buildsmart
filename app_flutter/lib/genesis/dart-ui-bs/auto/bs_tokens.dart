// 🛗 אטום-דאטה · קטלוג-הפיגמנטים (BsTokens) — הורם verbatim מהמקור-החי ע"י shelf-lift.
// מוצא: app_flutter/lib/theme/tokens.dart (בנייה-חכמה main). שכבה-0 של פירוק-המסכים.
import 'package:flutter/material.dart';

/// Design tokens ported from app/src/styles/tokens.css.
/// Single source of truth for spacing/color/typography across the Flutter app.
class BsTokens {
  BsTokens._();

  // Spacing scale (matches CSS --space-1..--space-6, 4-px base unit).
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 24;
  static const double space6 = 32;
  // W0 fine spacing — preserve existing look, give names.
  static const double spaceHair = 2; // hairline / divider gap (×90 raw)
  static const double space1_5 = 6; // between space1(4) and space2(8) (×128 raw)

  // Radii.
  static const double radiusPill = 999;
  static const double radiusCard = 20; // W0: standardized all card radii to 20
  static const double radiusCircle = 24; // FAB inner

  // Font sizes — bound from existing literals (token-equal · zero visual). P-3.
  static const double fontXs = 8; // chain_diagram caption
  static const double fontSm = 9; // chain_diagram label
  static const double fontMd = 14; // toast text
  static const double fontLg = 22; // chain_diagram glyph

  // W0 type-scale — 8 coherent steps mapping current usage; fractional sizes
  // (12.5/13.5/10.5) round to the nearest step (zero visual change).
  static const double typeCaption = 11;
  static const double typeMicro = 12;
  static const double typeLabel = 13;
  static const double typeBody = 14;
  static const double typeSubhead = 16;
  static const double typeTitleSm = 18;
  static const double typeTitleMd = 20;
  static const double typeTitleLg = 24;

  // Dial dimensions (matches .dial__circle: 48px).
  static const double dialCircle = 48;
  static const double dialIconSize = 22;
  static const double dialEmojiSize = 20;
  static const double fabSize = 56;

  // Animation timing.
  static const Duration dialIn = Duration(milliseconds: 280);
  static const Duration ssubIn = Duration(milliseconds: 240);
  static const Duration dialStaggerStep = Duration(milliseconds: 28); // per-row rise delay
  static const Duration toastDuration = Duration(seconds: 2);
  static const Duration transitionIn = Duration(milliseconds: 220); // W0: screen transition
  static const Duration microIn = Duration(milliseconds: 150); // W0: tap/expand micro-interaction
  static const Curve dialCurve = Cubic(0.2, 0.9, 0.3, 1.2);

  // Brand color. §W0 slice-2 (2026-08-16): deepened from #FF7A18 to a premium
  // construction orange — also lifts white-on-brand from 2.9:1 to 4.4:1 (clears
  // the 3:1 large-text/button bar). All hardcoded #FF7A18 across lib/ were swept
  // to this token in the same slice, so the deepening is uniform (no half/half).
  static const Color brand = Color(0xFFF26B1D);
  static const Color brandDark = Color(0xFFD65A0E);

  // Light theme colors.
  static const Color bgLight = Color(0xFFFAFAFA);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color inkLight = Color(0xFF1A1A1A);
  // §W0 slice-1 (2026-08-16): warm the muted grey (was #666666, a cold neutral)
  // to a warm grey biased toward the brand orange — 5.8:1 on white (passes AA).
  static const Color mutedLight = Color(0xFF6E655B);

  // W0 semantic status + surface tokens. success = bright #22C55E (chosen);
  // the rest promote the dominant existing hex (naming, not new values).
  // §W0 slice-3 (2026-08-16): grounded green (was bright #22C55E). Deeper reads
  // as more premium and lifts on-white contrast (2.2:1 → 3.5:1 for a fill/badge;
  // text still uses successDark). Swept from hardcoded #22C55E across lib/.
  static const Color success = Color(0xFF1F9D57);
  // Darker green for TEXT on a light background under high-contrast mode
  // (#22C55E-on-white is 2.28:1; this is ~5.0:1 — passes WCAG AA).
  static const Color successDark = Color(0xFF15803D);
  // §W0 slice-3 (2026-08-16): grounded status red (was #EF4444). Now 4.9:1 on
  // white — passes WCAG AA for text (was 3.2:1). Swept from hardcoded #EF4444.
  // NOTE: danger (status) and chainWarning (data-viz alert) USED to share #EF4444;
  // they now diverge deliberately — the viz keeps its brighter alert red below.
  static const Color danger = Color(0xFFCE3A32);
  // Darker red for TEXT on a light/white card (the successDark pattern):
  // Colors.redAccent-on-white is 3.19:1 (fails WCAG AA 4.5:1 for 14-15px
  // text); this red-700 is ~6.5:1 — passes AA. Use for 'יציאה'/'הסר' labels.
  static const Color dangerDark = Color(0xFFB91C1C);
  static const Color warnText = Color(0xFFB45309); // dark amber text
  static const Color warnBright = Color(0xFFF2A516); // bright amber badge
  static const Color divider = Color(0xFFE9E2D9); // §W0 slice-1: warm divider (was #EEEEEE cool)
  static const Color surfaceMid = Color(0xFFF5F5F5); // ×70 raw
  // Light tint of the brand orange (== brand #FF7A18 @ ~33% over white) — the
  // floating card-keyboard's seam/background fill: the app's OWN orange,
  // lightened so the white buttons read clearly on top (owner: a colour that
  // matches the app, derived from the brand — not an arbitrary peach).
  static const Color kbSeam = Color(0xFFFBCEB4); // §W0 slice-2: retint from deepened brand

  // Chat-specific text colors (light background, high-contrast).
  static const Color chatText = Color(0xFF111111);
  static const Color chatTimestamp = Color(0xFF777777);

  // Dark theme colors — still used by AppTheme.dark(), dial & toast.
  // §W0 slice-1 (2026-08-16): warmed the whole dark palette from a COOL blue-black
  // (#0E1116/#181D26/#F1F3F8/#9AA3B2) to a WARM industrial dark — easier on the
  // eyes on-site and matching the brand's warmth. AA-verified: inkDark 16.4:1 on
  // bgDark, mutedDark 7.3:1 on bgDark / 6.5:1 on cardDark.
  static const Color bgDark = Color(0xFF141009);
  static const Color cardDark = Color(0xFF1F1A13);
  static const Color inkDark = Color(0xFFF4EEE4);
  static const Color mutedDark = Color(0xFFA89E90);

  // Chain-diagram data-viz palette (material stripes + joint edges). Bound from
  // existing literals in chain_diagram.dart — token-equal · zero visual. P-1.
  static const Color chainCyan = Color(0xFF22D3EE); // HDPE / cold supply / hdpe-press / implicit bridge
  static const Color chainOrange = Color(0xFFFB923C); // PEX / pex-press
  static const Color chainCopper = Color(0xFFEA580C); // copper / copper-press
  static const Color chainBrass = Color(0xFFEAB308); // brass / bsp thread
  static const Color chainGray = Color(0xFF94A3B8); // PVC / drainage
  static const Color chainSlate = Color(0xFF64748B); // PP
  static const Color chainPurple = Color(0xFFA855F7); // multi-layer
  static const Color chainCeramic = Color(0xFFE2E8F0); // ceramic
  static const Color chainRubber = Color(0xFF334155); // rubber
  static const Color chainSteel = Color(0xFF475569); // steel
  static const Color chainStainless = Color(0xFFCBD5E1); // stainless
  static const Color chainDefault = Color(0xFF7C8AA5); // neutral fallback / SKU caption
  static const Color chainWarning = Color(0xFFEF4444); // bottleneck warning ring

  // Light theme scaffold background (the app-wide light ground).
  // §W0 slice-1 (2026-08-16): warm off-white paper (was #F5F6FA, a cool blue-grey)
  // — the single most visible light-mode warm-up. Non-text ground, no AA concern.
  static const Color bgLightAlt = Color(0xFFFAF8F5);

  // Shadow used for dial circles + label pills.
  static const List<BoxShadow> circleShadow = [
    BoxShadow(
      color: Color(0x59000000), // 0 6px 18px -8px rgba(0,0,0,.35) — flattened
      blurRadius: 18,
      offset: Offset(0, 6),
      spreadRadius: -8,
    ),
  ];

  static const List<BoxShadow> labelShadow = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: -6,
    ),
  ];
}
