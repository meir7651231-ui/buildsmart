import { useEffect, useRef, useState } from 'preact/hooks';
import { startVoiceRecognition, isVoiceSupported } from '../../lib/voice';
import { searchQuery } from '../../store/search-store';

type Props = { onClose: () => void };

export function VoiceModal({ onClose }: Props) {
  const [text, setText] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [listening, setListening] = useState(true);
  const stopRef = useRef<(() => void) | null>(null);

  useEffect(() => {
    if (!isVoiceSupported()) {
      setError('הדפדפן הזה לא תומך בחיפוש קולי. הקלד את החיפוש ידנית.');
      setListening(false);
      return;
    }
    const session = startVoiceRecognition({
      onTranscript: (t, isFinal) => {
        setText(t);
        if (isFinal && t) {
          searchQuery.value = t;
          onClose();
        }
      },
      onEnd: () => setListening(false),
      onError: (msg) => setError(msg),
    });
    stopRef.current = session?.stop ?? null;
    return () => stopRef.current?.();
  }, []);

  const useText = () => {
    if (text.trim()) searchQuery.value = text.trim();
    onClose();
  };

  return (
    <div class="sheet" role="dialog" aria-modal="true" aria-label="חיפוש קולי">
      <button type="button" class="sheet__backdrop" aria-label="סגור" onClick={onClose} />
      <div class="sheet__panel sheet__panel--voice">
        <div class="sheet__handle" aria-hidden="true" />
        <div class={`vmic${listening ? ' is-on' : ''}`}>
          <svg viewBox="0 0 24 24" width="56" height="56" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
            <rect x="9" y="2" width="6" height="12" rx="3" />
            <path d="M5 11a7 7 0 0014 0M12 18v4M8 22h8" />
          </svg>
        </div>
        <p class="vmic__status">
          {error ? error : listening ? 'מאזין...' : text ? 'תמלול הסתיים' : 'לחץ והתחל לדבר'}
        </p>
        {text && <p class="vmic__text">"{text}"</p>}
        <div class="vmic__actions">
          {text && (
            <button type="button" class="vmic__primary" onClick={useText}>
              חפש
            </button>
          )}
          <button type="button" class="vmic__close" onClick={onClose}>
            ביטול
          </button>
        </div>
      </div>
    </div>
  );
}
