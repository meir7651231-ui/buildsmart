import { useEffect, useRef, useState } from 'preact/hooks';
import { startBarcodeScanner, isBarcodeSupported } from '../../lib/barcode';
import { searchQuery, setActiveTool } from '../../store/search-store';

export function BarcodeMode() {
  const videoRef = useRef<HTMLVideoElement>(null);
  const sessionRef = useRef<{ stop: () => void } | null>(null);
  const [scanning, setScanning] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [detected, setDetected] = useState<string | null>(null);

  const stopScan = () => {
    sessionRef.current?.stop();
    sessionRef.current = null;
    setScanning(false);
  };

  const startScan = async () => {
    if (!isBarcodeSupported()) {
      setError('הדפדפן הזה לא תומך בסריקת ברקוד. נסה ב-Chrome / Edge.');
      return;
    }
    const v = videoRef.current;
    if (!v) return;
    setError(null);
    setDetected(null);
    setScanning(true);
    const s = await startBarcodeScanner(
      v,
      (value) => {
        setDetected(value);
        searchQuery.value = value;
        stopScan();
        setTimeout(() => setActiveTool(null), 500);
      },
      (msg) => {
        setError(msg);
        setScanning(false);
      },
    );
    sessionRef.current = s;
  };

  useEffect(() => {
    return () => stopScan();
  }, []);

  return (
    <div class="bcmode">
      <div class={`bcmode__frame${scanning ? ' is-on' : ''}`}>
        <video ref={videoRef} muted playsinline class="bcmode__video" />
        {!scanning && !detected && (
          <button type="button" class="bcmode__cam-btn" aria-label="הפעל מצלמה" onClick={startScan}>
            <svg viewBox="0 0 24 24" width="56" height="56" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
              <path d="M3 7h4l2-3h6l2 3h4v12H3z" />
              <circle cx="12" cy="13" r="4" />
            </svg>
          </button>
        )}
        {scanning && <div class="bcmode__reticle" aria-hidden="true" />}
      </div>
      <p class="vmode__hint">
        {error
          ? error
          : detected
            ? `זוהה: ${detected}`
            : scanning
              ? 'כוון את המצלמה אל הברקוד'
              : 'הקש על אייקון המצלמה כדי להתחיל'}
      </p>
    </div>
  );
}
