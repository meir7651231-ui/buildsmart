export type Category = {
  id: string;
  name: string;
  emoji: string;
  parentId: string | null;
};

export const CATEGORIES: Category[] = [
  { id: 'build', name: 'בנייה', emoji: '🧱', parentId: null },
  { id: 'plumb', name: 'אינסטלציה', emoji: '🚿', parentId: null },
  { id: 'elec', name: 'חשמל', emoji: '⚡', parentId: null },
  { id: 'tools', name: 'כלים', emoji: '🔨', parentId: null },
  { id: 'finish', name: 'גמר', emoji: '🎨', parentId: null },
  { id: 'safety', name: 'בטיחות', emoji: '🦺', parentId: null },

  { id: 'build.block', name: 'בלוקים', emoji: '🟫', parentId: 'build' },
  { id: 'build.cement', name: 'מלט וטיט', emoji: '🪨', parentId: 'build' },
  { id: 'build.aggr', name: 'חצץ וחול', emoji: '⛰️', parentId: 'build' },
  { id: 'build.rebar', name: 'ברזל זיון', emoji: '🪵', parentId: 'build' },
  { id: 'build.formwork', name: 'תבניות', emoji: '🟨', parentId: 'build' },

  { id: 'plumb.pipe', name: 'צינורות', emoji: '🟢', parentId: 'plumb' },
  { id: 'plumb.fitting', name: 'מחברים', emoji: '🔩', parentId: 'plumb' },
  { id: 'plumb.tap', name: 'ברזים', emoji: '🚰', parentId: 'plumb' },
  { id: 'plumb.drain', name: 'ניקוז', emoji: '🕳️', parentId: 'plumb' },

  { id: 'elec.cable', name: 'כבלים', emoji: '🔌', parentId: 'elec' },
  { id: 'elec.socket', name: 'שקעים', emoji: '◽', parentId: 'elec' },
  { id: 'elec.switch', name: 'מפסקים', emoji: '⬜', parentId: 'elec' },
  { id: 'elec.board', name: 'לוחות חשמל', emoji: '🔲', parentId: 'elec' },

  { id: 'tools.hand', name: 'כלי יד', emoji: '🔧', parentId: 'tools' },
  { id: 'tools.power', name: 'כלי חשמל', emoji: '🪚', parentId: 'tools' },
  { id: 'tools.drill', name: 'מקדחים', emoji: '🪛', parentId: 'tools' },
  { id: 'tools.ladder', name: 'סולמות', emoji: '🪜', parentId: 'tools' },

  { id: 'finish.paint', name: 'צבע', emoji: '🎨', parentId: 'finish' },
  { id: 'finish.tile', name: 'אריחים', emoji: '⬛', parentId: 'finish' },
  { id: 'finish.gypsum', name: 'גבס', emoji: '⬜', parentId: 'finish' },
  { id: 'finish.floor', name: 'פרקט וריצוף', emoji: '🟫', parentId: 'finish' },

  { id: 'safety.helmet', name: 'קסדות', emoji: '⛑️', parentId: 'safety' },
  { id: 'safety.gloves', name: 'כפפות', emoji: '🧤', parentId: 'safety' },
  { id: 'safety.vest', name: 'אפודים', emoji: '🦺', parentId: 'safety' },
  { id: 'safety.boots', name: 'נעלי בטיחות', emoji: '🥾', parentId: 'safety' },
];

export function childrenOf(parentId: string | null): Category[] {
  return CATEGORIES.filter((c) => c.parentId === parentId);
}

export function categoryById(id: string): Category | undefined {
  return CATEGORIES.find((c) => c.id === id);
}

export function pathLabels(path: string[]): string[] {
  return path.map((id) => categoryById(id)?.name ?? id);
}
