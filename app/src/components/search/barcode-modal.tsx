import { useEffect, useRef, useState } from 'preact/hooks';
import { startBarcodeScanner, isBarcodeSupported } from '../../lib/barcode';
import { searchQuery } from '../../store/search-store';

type Props = { onClose: () => void };

export function BarcodeModal({ onClose }: Props) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [error, setError] = useState<string | null>(null);
  const [detected, setDetected] = useState<string | null>(null);
  const sessionRef = useRef<{ stop: () => void } | null>(null);

  useEffect(() => {
    if (!isBarcodeSupported()) {
      setError('הדפדפן הזה לא תומך בסריקת ברקוד. נסה ב-Chrome / Edge.');
      return;
    }
    const v = videoRef.current;
    if (!v) return;
    let cancelled = false;
    (async () => {
      const s = await startBarcodeScanner(
        v,
        (value) => {
          if (cancelled) return;
          setDetected(value);
          searchQuery.value = value;
          sessionRef.current?.stop();
          setTimeout(onClose, 700);
        },
        (msg) => setError(msg),
      );
      sessionRef.current = s;
    })();
    return () => {
      cancelled = true;
      sessionRef.current?.stop();
    };
  }, []);

  return (
    <div class="sheet" role="dialog" aria-modal="true" aria-label="סריקת ברקוד">
      <button type="button" class="sheet__backdrop" aria-label="סגור" onClick={onClose} />
      <div class="sheet__panel sheet__panel--barcode">
        <div class="sheet__handle" aria-hidden="true" />
        <h2 class="bc__title">סרוק ברקוד</h2>
        <p class="bc__hint">{error ?? 'כוון את המצלמה אל הברקוד'}</p>
        {!error && (
          <div class="bc__frame">
            <video ref={videoRef} muted playsinline class="bc__video" />
            <div class="bc__reticle" aria-hidden="true" />
          </div>
        )}
        {detected && <p class="bc__detected">זוהה: {detected}</p>}
        <button type="button" class="vmic__close" onClick={onClose}>
          סגור
        </button>
      </div>
    </div>
  );
}
