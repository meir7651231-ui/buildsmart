import { useEffect, useRef } from 'preact/hooks';
import { searchOpen, closeSearch } from '../../store/app-store';
import { searchQuery, activeTool, resetSearch } from '../../store/search-store';
import { ToolsRail } from './tools-dial';
import { ScopeChips } from './scope-chips';
import { ResultsList } from './results-list';
import { VoiceSubmenu } from './submenu-voice';
import { BarcodeSubmenu } from './submenu-barcode';
import { FiltersSubmenu } from './submenu-filters';
import { SortSubmenu } from './submenu-sort';

export function SearchPanel() {
  if (!searchOpen.value) return null;
  return <SearchPanelInner />;
}

function SearchPanelInner() {
  const inputRef = useRef<HTMLInputElement>(null);
  const tool = activeTool.value;

  useEffect(() => {
    searchQuery.value = '';
    activeTool.value = null;
    const t = setTimeout(() => inputRef.current?.focus(), 60);
    return () => clearTimeout(t);
  }, []);

  const handleClose = () => {
    resetSearch();
    closeSearch();
  };

  return (
    <>
      <button
        type="button"
        class="spanel__backdrop"
        aria-label="סגור"
        onClick={handleClose}
      />

      <div class="spanel__stage">{!tool && <ResultsList />}</div>

      <div class="spanel__rail">
        {tool === 'voice' && <VoiceSubmenu />}
        {tool === 'barcode' && <BarcodeSubmenu />}
        {tool === 'filters' && <FiltersSubmenu />}
        {tool === 'sort' && <SortSubmenu />}
        <ToolsRail />
      </div>

      {!tool && <ScopeChips />}

      <div class="sinput">
        <span class="sinput__icon" aria-hidden="true">
          <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
            <circle cx="11" cy="11" r="7" />
            <line x1="20" y1="20" x2="16.5" y2="16.5" />
          </svg>
        </span>
        <input
          ref={inputRef}
          type="search"
          inputMode="search"
          class="sinput__field"
          placeholder="חיפוש מוצרים, קטגוריות, מסכים..."
          value={searchQuery.value}
          onInput={(e) => (searchQuery.value = (e.target as HTMLInputElement).value)}
        />
        {searchQuery.value && (
          <button
            type="button"
            class="sinput__clear"
            aria-label="נקה"
            onClick={() => {
              searchQuery.value = '';
              inputRef.current?.focus();
            }}
          >
            ✕
          </button>
        )}
      </div>
    </>
  );
}
