import '../dart/wf_stage_label.dart';
// 🗄️ דאטה · מילוני-wf_stage_label — הורמו מהאטום ע"י purify-dart-native (הכרעת-בעלים "עד
// מאה אחוז": אפס-דאטה במנגנון). מוזרקים לאטום כשקעים-שמיים; שינוי-מילון = עריכה כאן.
// מקור-ערכים: new/dart/wf_stage_label.dart (verbatim).
const Map<WfStage, String> kStageFallback = {
  WfStage.intake: 'חדש',
  WfStage.prep: 'בהכנה',
  WfStage.ready: 'מוכן',
  WfStage.dispatch: 'מסירה',
  WfStage.done: 'הושלם',
};
