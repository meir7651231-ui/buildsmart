// ⚛️ אטום-Dart (דרגת-חוזה) · managerMorningBriefPrompt
// תפקיד: בונה את מחרוזת-ה-prompt ל"תדריך-בוקר" — מצב-העסק (context) + הנחיית-הפלט הקבועה.
// מוצא: buildsmart/app_flutter/lib/logic/manager_copilot.dart:109-116 (‏managerMorningBriefPrompt; חוק-4).
// אחים: אין. אפס-שקע (הכול מחרוזות-קבועות + [context]).
// טוהר: dart:core בלבד; אפס import, אפס state.

/// מחרוזת prompt לתדריך-בוקר: מצב-אמת [context] + הנחיית 3-4 נקודות-תבליט.
/// verbatim manager_copilot.dart:109-116.
String managerMorningBriefPrompt(String context, {required String Function(String) term}) {
  return '${term('xi_mtsbhask-kat-ntvnyamt')}$context\n\n'
      '${term('xi_ktvb-tdrykbvkr-ktsr-lbalym-nkvdvttblyt-al-mh-shdvrsh-tshvmtlb-hyvm')}'
      '${term('xi_hzmnvt-tkvavtptvchvt-nytsvlashray-gbvh-lkvch-bvlt')}'
      '${term('xi_ak-vrk-lpy-hntvnym-shlmalh-bly-lhmtsya-ayn-ntvnyabrmgmh')}'
      '${term('xi_ptch-b-tdrykbvkr')}';
}
