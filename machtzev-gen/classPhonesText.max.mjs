// 🤖 AUTO-EMITTED by gen-max — classPhonesText (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function classPhonesText_ORIG(contacts) {
    return contacts.map((c) => c.phone).filter(Boolean).join(', ');
}
function classContacts(db, courseId) {
    const out = [];
    const seenPhone = new Set();
    for (const e of db.enrollments) {
        if (e.courseId !== courseId || e.status === 'ended' || e.status === 'wait')
            continue;
        for (const f of db.families) {
            const m = f.members.find((x) => x.id === e.memberId);
            if (!m)
                continue;
            const phone = f.phone || m.phone || '';
            if (phone && seenPhone.has(phone))
                break; // אותה משפחה — הודעה אחת
            if (phone)
                seenPhone.add(phone);
            out.push({ id: e.id, name: m.first + ' · ' + f.name, phone });
            break;
        }
    }
    return out;
}
export function classPhonesText(contacts) { return classPhonesText_ORIG(contacts); }
export function classPhonesText_fromSource(db, courseId) { return classPhonesText_ORIG(classContacts(db, courseId)); }
