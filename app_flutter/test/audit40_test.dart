import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/screens/compat_screen.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct? _f(String s) {
  try { return kCompatCatalog.firstWhere((p) => p.sku == s); } catch (_) { return null; }
}

int _trans(List<LipskeyCatalogProduct> p) { var n=0;
  for (var i=0;i<p.length-1;i++){final a=kVerifiedSpecs[p[i].sku]?.material,b=kVerifiedSpecs[p[i+1].sku]?.material;
    if(a!=null&&b!=null&&a!=b)n++;} return n; }

String _flags(List<LipskeyCatalogProduct> path) {
  final f = <String>[];
  for (var i=1;i<path.length-1;i++){ final p=path[i];
    if (flowRole(p)==FlowRole.accessory) f.add('ACCESSORY:${p.nameHe}');
    if (flowRole(p)==FlowRole.fixture)   f.add('FIXTURE-MID:${p.nameHe}');
    if (!isFitting(p))                  f.add('DEVICE:${p.nameHe}');
    if (kVerifiedSpecs[p.sku]==null)     f.add('NOSPEC:${p.nameHe}');
  }
  return f.isEmpty ? '' : '  🚩 ${f.join(", ")}';
}

void _run(int n, String desc, String from, String to, {bool expectPath=true, int depth=7}) {
  final a=_f(from), b=_f(to);
  if (a==null||b==null){ print('$n. ?? SKU חסר ($from/$to)'); return; }
  final path=findShortestPath(a,b,maxDepth:depth,tempC:20);
  final got = path!=null;
  final ok = got==expectPath;
  final mark = ok?'✓':'✗✗✗';
  if (!got){ print('$n. $mark $desc → אין נתיב'); return; }
  print('$n. $mark $desc → ${path.length} | trans=${_trans(path)} | '
      '${path.map((p)=>p.nameHe).join(" → ")}${_flags(path)}');
}

void main() {
  test('AUDIT 40', () {
    print('\n════════ אספקה תוך-מערכתי (1-12) ════════');
    _run(1,'קיסר → פקק נחושת ½"','779096G','77778071');
    _run(2,'אל-חוזר ½" → ברז מעבר פ.פ ½"','77004401','77777201');
    _run(3,'ברז גן ¾" → ברז כיור ½"','77777345','77777114');
    _run(4,'ניפל נחושת ½" → ברז מעבר פ.פ ½"','77777641','77777201');
    _run(5,'ברז מעבר 1" → קיסר ½"','77777313','779096G');
    _run(6,'ברז מעבר 2" → קיסר ½"','77777316','779096G');
    _run(7,'NTM 16 → NTM 25','77401622','77401535');
    _run(8,'NTM 32 → NTM 16','40132444','77401622');
    _run(9,'מופה נחושת ½" → ברז כיור ½"','77777104','77777114');
    _run(10,'בושינג ¾×½ → פקק נחושת ½"','77777661','77778071');
    _run(11,'ברז גן ½" → אל-חוזר ½"','77777341','77004401');
    _run(12,'מעבר ניקל ½×¾ → ברז מעבר ¾"','8315','77777202');

    print('\n════════ ניקוז תוך-מערכתי (13-24) ════════');
    _run(13,'ברך PVC 110 → צינור אפור 110','142289','116113');
    _run(14,'מחסום DN32 → צינור אפור DN32','217861','116180');
    _run(15,'סיפון → מחסום גלוי','77003221','116635');
    _run(16,'תעלת ניקוז → צינור DN50','77575327','221022');
    _run(17,'צינור PP 110 → ברך PVC 110','224169','142289');
    _run(18,'מולטי DN75 → ברך PVC 75','273216','116033');
    _run(19,'אטם DN50 → צינור DN50','506525','221022');
    _run(20,'מסעף 45 DN50 → צינור DN50','116565','221022');
    _run(21,'מחסום גלוי → צינור 110','116635','116113');
    _run(22,'ברך אסלה → צינור 110','164873','116113');
    _run(23,'מחסום DN32 → סיפון DN32','217861','77003221');
    _run(24,'צינור 110 → מסעף 45','116113','116565');

    print('\n════════ חוצה-מערכת — חייב אין נתיב (25-34) ════════');
    _run(25,'קיסר → צינור ניקוז 110','779096G','116113',expectPath:false);
    _run(26,'ברז כיור → ברך אסלה','77777114','164873',expectPath:false);
    _run(27,'ברז גן ¾" → סיפון','77777345','77003221',expectPath:false);
    _run(28,'ניפל נחושת → צינור 110','77777641','116113',expectPath:false);
    _run(29,'פקק נחושת → מחסום DN32','77778071','217861',expectPath:false);
    _run(30,'NTM 25 → תעלת ניקוז','77401535','77575327',expectPath:false);
    _run(31,'אל-חוזר ½" → צינור DN50','77004401','221022',expectPath:false);
    _run(32,'ברז מעבר 2" → ברך PVC 110','77777316','142289',expectPath:false);
    _run(33,'מופה נחושת → מחסום גלוי','77777104','116635',expectPath:false);
    _run(34,'בושינג ¾×½ → צינור 110','77777661','116113',expectPath:false);

    print('\n════════ קבועה כקצה + התקנות (35-40) ════════');
    _run(35,'קיסר → אסלה (כניסה)','779096G','77771006');
    _run(36,'אסלה → צינור ניקוז (יציאה)','77771006','116113');
    _run(37,'ברז מעבר ½" → אסלה','77777311','77771006');
    _run(38,'אסלה → מסעף 45','77771006','116565');
    _run(39,'ברז כיור → אסלה','77777114','77771006');
    _run(40,'אסלה(2) → צינור 110','77771010','116113');
  });
}
