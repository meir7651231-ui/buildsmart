import { useEffect, useRef, useState } from 'preact/hooks';
import { startVoiceRecognition, isVoiceSupported } from '../../lib/voice';
import { searchQuery, setActiveTool } from '../../store/search-store';

const LONG_PRESS_MS = 280;

export function VoiceMode() {
  const [listening, setListening] = useState(false);
  const [transcript, setTranscript] = useState('');
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
    setTranscript('');
    setListening(true);
    const session = startVoiceRecognition({
      onTranscript: (t, isFinal) => {
        setTranscript(t);
        searchQuery.value = t;
        if (isFinal && autoCommit && t.trim()) {
          /* short-tap: commit and return to dial */
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

  useEffect(() => {
    return () => stopListening();
  }, []);

  /* Short tap: toggle single-shot. Long press: listen while held. */
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
      /* Short tap: toggle */
      if (listening) {
        stopListening();
      } else {
        startListening(true);
      }
    }
    isLongPress.current = false;
  };

  return (
    <div class="vmode">
      <button
        type="button"
        class={`vmode__mic${listening ? ' is-listening' : ''}`}
        aria-label={listening ? 'מקליט — שחרר להפסקה' : 'הקש להפעלה או החזק לדיבור ממושך'}
        onPointerDown={onPointerDown}
        onPointerUp={onPointerUp}
        onPointerCancel={onPointerUp}
      >
        <svg viewBox="0 0 24 24" width="64" height="64" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
          <rect x="9" y="2" width="6" height="12" rx="3" />
          <path d="M5 11a7 7 0 0014 0M12 18v4M8 22h8" />
        </svg>
      </button>
      <p class="vmode__hint">
        {error
          ? error
          : listening
            ? 'מאזין... דבר בקול ברור'
            : transcript
              ? '"' + transcript + '"'
              : 'הקש פעם להפעלה   ·   החזק לדיבור ממושך'}
      </p>
    </div>
  );
}
