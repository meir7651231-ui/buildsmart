import { useEffect, useRef, useState } from 'preact/hooks';
import { startVoiceRecognition, isVoiceSupported } from '../../lib/voice';
import { searchQuery, setActiveTool } from '../../store/search-store';

const LONG_PRESS_MS = 280;

export function VoiceSubmenu() {
  const [listening, setListening] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const sessionRef = useRef<{ stop: () => void } | null>(null);
  const longPressTimer = useRef<number | null>(null);
  const isLongPress = useRef(false);

  const stopListening = () => {
    sessionRef.current?.stop();
    sessionRef.current = null;
    setListening(false);
  };

  const startListening = (autoCommit: boolean) => {
    if (!isVoiceSupported()) {
      setError('הדפדפן הזה לא תומך בחיפוש קולי');
      return;
    }
    setError(null);
    setListening(true);
    const session = startVoiceRecognition({
      onTranscript: (t, isFinal) => {
        searchQuery.value = t;
        if (isFinal && autoCommit && t.trim()) {
          stopListening();
          setActiveTool(null);
        }
      },
      onEnd: () => {
        sessionRef.current = null;
        setListening(false);
      },
      onError: (msg) => {
        setError(msg);
        setListening(false);
      },
    });
    sessionRef.current = session;
  };

  useEffect(() => () => stopListening(), []);

  const onPointerDown = (e: PointerEvent) => {
    (e.currentTarget as Element).setPointerCapture?.(e.pointerId);
    isLongPress.current = false;
    longPressTimer.current = window.setTimeout(() => {
      isLongPress.current = true;
      if (!listening) startListening(false);
    }, LONG_PRESS_MS);
  };

  const onPointerUp = () => {
    if (longPressTimer.current) {
      clearTimeout(longPressTimer.current);
      longPressTimer.current = null;
    }
    if (isLongPress.current) {
      stopListening();
    } else {
      listening ? stopListening() : startListening(true);
    }
    isLongPress.current = false;
  };

  return (
    <div class="ssub">
      <button
        type="button"
        class={`ssub__row${listening ? ' is-on' : ''}`}
        onPointerDown={onPointerDown}
        onPointerUp={onPointerUp}
        onPointerCancel={onPointerUp}
        aria-label="הקלטה — הקש פעם או החזק לדיבור ממושך"
      >
        <span class="ssub__icon">
          <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
            <rect x="9" y="2" width="6" height="12" rx="3" />
            <path d="M5 11a7 7 0 0014 0M12 18v4M8 22h8" />
          </svg>
        </span>
        <span class="ssub__label">
          {error ? error : listening ? 'מאזין... שחרר לסיום' : 'הקש להפעלה · החזק לדיבור'}
        </span>
      </button>
    </div>
  );
}
