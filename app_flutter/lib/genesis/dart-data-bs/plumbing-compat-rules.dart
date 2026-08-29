// 🗄️ דאטה · חוקות-החיבור המחוברות של סחר-האינסטלציה — 5 חוקות-זוג + חוקת-ההשלמה הגלוונית.
// **זו דאטה מחוברת (authored catalog), לא מנוע** (הכרעה-13: דאטה=שקע; הכרעת-בעלים "אפס-דאטה במנוע").
// מוצא: buildsmart/app_flutter/lib/domain/seeds/plumbing_trade_seed.dart —
//   plumbingCompatRules :328-348 · plumbingCompletionRules :354-367 (חוק-4 — ערכים ביט-זהים).
//   ⚠️ קו-האמת: הקובץ אינו קיים על main של buildsmart — חולץ מ-origin/claude/align-main
//   ≡ origin/claude/whats-happening-LyY9G (md5 זהה, 434402dc…) — ענף-העבודה החי של app_flutter.
// הצורה: שורות-record טהורות (typedef בלבד, אפס-class) — סכמת-המנוע (CompatibilityRule)
//   חיה אצל אטום-המנוע (new/dart/end_pair.dart, שקע-`rules`); הקופסה ממפה שורה→חוקה בחיווט.
//   sizeMatch / severity = שמות-enum כמחרוזות — מפוענחים ע"י size_match_from (מפענח-סובלני לפי .name).
// הנגזרות קובעו כליטרלים (המקור גוזר אותן דטרמיניסטית — הבדיקה מוכיחה את הגזירה מחדש):
//   • id-חוקה  = 'plumbing.rule.<a.name>__<b.name>'   (plumbing_trade_seed.dart:339)
//   • id-טיפוס = 'plumbing.conn.<e.name>'             (_connTypeId :40 — קודם כ-new/dart/conn_type_id.dart)
//   • הסדר    = ממוין-לפי-id (compareTo :347) — סדר-ההזרקה לשקע-rules של endPair (סדר=עדיפות).
// המקור: methodLabelHe הוא KEYSTONE-CRITICAL — ביט-זהה ל-install_engine.dart connectionMethodLabel
//   (‏plumbing_trade_seed.dart:324-327); כל אי-התאמת-גודל = critical.
// חוקת-ההשלמה: whenInLineHasTypeId/requireTypeId = '' **במכוון** — קורוזיה גלוונית היא לפי-חומר,
//   לא לפי-טיפוס-מחבר; הרזולבר קורא את incompatibleMaterialGroups (‏plumbing_trade_seed.dart:350-353).
// שינוי-חוקה / תרגום = עריכת-שורה כאן. אפס-נגיעה במנוע (end_pair.dart).

/// שורת חוקת-זוג (compat) — ערכים בלבד; הסכמה אצל המנוע.
typedef PlumbingCompatRuleRow = ({
  String id,
  String tradeId,
  String aTypeId,
  String bTypeId,
  String sizeMatch, // שם-ערך של SizeMatch (מפוענח ב-sizeMatchFrom)
  String methodLabelHe,
  String onMismatch, // שם-ערך של RuleSeverity
});

/// שורת חוקת-השלמה (completion) — ערכים בלבד; הסכמה אצל המנוע.
typedef PlumbingCompletionRuleRow = ({
  String id,
  String tradeId,
  String whenInLineHasTypeId,
  String requireTypeId,
  String whyHe,
  List<String> incompatibleMaterialGroups,
  String requiredInterposerWhyHe,
  String severity, // שם-ערך של RuleSeverity
});

/// 5 חוקות-הזוג same-type/תבריג — ממוינות-לפי-id, ביט-זהות לפלט
/// `plumbingCompatRules()` שבמקור (plumbing_trade_seed.dart:328-348).
const List<PlumbingCompatRuleRow> kPlumbingCompatRules = [
  (
    id: 'plumbing.rule.bspMale__bspFemale',
    tradeId: 'plumbing',
    aTypeId: 'plumbing.conn.bspMale',
    bTypeId: 'plumbing.conn.bspFemale',
    sizeMatch: 'exactSame',
    methodLabelHe: 'תבריג + PTFE',
    onMismatch: 'critical',
  ),
  (
    id: 'plumbing.rule.copperPress__copperPress',
    tradeId: 'plumbing',
    aTypeId: 'plumbing.conn.copperPress',
    bTypeId: 'plumbing.conn.copperPress',
    sizeMatch: 'exactSame',
    methodLabelHe: 'Press / O-ring',
    onMismatch: 'critical',
  ),
  (
    id: 'plumbing.rule.drainOpening__drainOpening',
    tradeId: 'plumbing',
    aTypeId: 'plumbing.conn.drainOpening',
    bTypeId: 'plumbing.conn.drainOpening',
    sizeMatch: 'exactSame',
    methodLabelHe: 'כיסוי ניקוז',
    onMismatch: 'critical',
  ),
  (
    id: 'plumbing.rule.hdpeCompression__hdpeCompression',
    tradeId: 'plumbing',
    aTypeId: 'plumbing.conn.hdpeCompression',
    bTypeId: 'plumbing.conn.hdpeCompression',
    sizeMatch: 'exactSame',
    methodLabelHe: 'אום הידוק (compression)',
    onMismatch: 'critical',
  ),
  (
    id: 'plumbing.rule.pexPress__pexPress',
    tradeId: 'plumbing',
    aTypeId: 'plumbing.conn.pexPress',
    bTypeId: 'plumbing.conn.pexPress',
    sizeMatch: 'exactSame',
    methodLabelHe: 'Press / טבעת כיווץ',
    onMismatch: 'critical',
  ),
];

/// חוקת-ההשלמה הגלוונית היחידה — ביט-זהה לפלט `plumbingCompletionRules()`
/// שבמקור (plumbing_trade_seed.dart:354-367).
const List<PlumbingCompletionRuleRow> kPlumbingCompletionRules = [
  (
    id: 'plumbing.completion.galvanic',
    tradeId: 'plumbing',
    whenInLineHasTypeId: '',
    requireTypeId: '',
    whyHe:
        'מתכות לא-דומות (נחושת/פליז ↔ פלדה/נירוסטה) באותו קו דורשות מתאם דיאלקטרי למניעת קורוזיה גלוונית',
    incompatibleMaterialGroups: ['copper-group', 'iron-group'],
    requiredInterposerWhyHe:
        'מתאם דיאלקטרי (ניתוק גלווני בין קבוצות-מתכת לא-דומות)',
    severity: 'critical',
  ),
];
