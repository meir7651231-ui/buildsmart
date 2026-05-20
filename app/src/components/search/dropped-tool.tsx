import { setActiveTool, type ToolKind } from '../../store/search-store';
import { TOOLS } from './tools-dial';

type Props = { tool: ToolKind };

export function DroppedTool({ tool }: Props) {
  const def = TOOLS.find((t) => t.id === tool);
  if (!def) return null;
  return (
    <button
      type="button"
      class="sdrop"
      onClick={() => setActiveTool(null)}
      aria-label={`חזרה לכלי החיפוש (${def.label})`}
    >
      <span class="sdrop__back" aria-hidden="true">
        <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
          <path d="M7 12h13M13 6l-6 6 6 6" />
        </svg>
      </span>
      <span class="sdrop__label">{def.label}</span>
      <span class="sdrop__icon">{def.icon}</span>
    </button>
  );
}
