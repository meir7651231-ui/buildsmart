// 🤖 AUTO-EMITTED by gen-max — sheetSummary (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function sheetRoster(enrollments, courseId) {
    return enrollments.filter((e) => e.courseId === courseId && e.status !== 'ended' && e.status !== 'wait');
}
export function sheetSummary(roster, dateIso) { return sheetSummary_ORIG(roster, dateIso); }
export function sheetSummary_fromSource(enrollments, courseId, dateIso) { return sheetSummary_ORIG(sheetRoster(enrollments, courseId), dateIso); }
