// 🤖 AUTO-EMITTED by gen-max — needLabel (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
const ORG_NEEDS = [
    { id: 'crm', emoji: '👥', label: 'ניהול לקוחות ואנשי קשר' },
    { id: 'billing', emoji: '🧾', label: 'גבייה, תשלומים וקבלות' },
    { id: 'schedule', emoji: '📅', label: 'יומן, שיבוצים ותורים' },
    { id: 'inventory', emoji: '📦', label: 'מלאי, מוצרים ושירותים' },
    { id: 'reports', emoji: '📊', label: 'דוחות ותובנות' },
    { id: 'multi', emoji: '🏢', label: 'ריבוי סניפים / צוות גדול' },
    { id: 'backup', emoji: '🔒', label: 'גיבוי ואבטחת מידע' },
];
const WIZARD_INDUSTRIES = VERTICAL_PACKS.map((p) => ({
    id: p.id,
    emoji: p.emoji,
    label: p.label,
    sub: p.sub,
}));
export function needLabel_ORIG(id) {
    return ORG_NEEDS.find((n) => n.id === id)?.label ?? id;
}
function industryLabel(id) {
    return WIZARD_INDUSTRIES.find((i) => i.id === id)?.label ?? id ?? '—';
}
export function needLabel(id) { return needLabel_ORIG(id); }
export function needLabel_fromSource(id) { return needLabel_ORIG(industryLabel(id)); }
