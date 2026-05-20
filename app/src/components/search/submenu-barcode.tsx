import { useEffect, useRef, useState } from 'preact/hooks';
import { startBarcodeScanner, isBarcodeSupported } from '../../lib/barcode';
import { searchQuery, setActiveTool } from '../../store/search-store';

export function BarcodeSubmenu() {
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
      setError('הדפדפן לא תומך');
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
        setTimeout(() => setActiveTool(null), 400);
      },
      (msg) => {
        setError(msg);
        setScanning(false);
      },
    );
    sessionRef.current = s;
  };

  useEffect(() => () => stopScan(), []);

  return (
    <div class="ssub">
      {scanning && (
        <div class="ssub__video-row">
          <video ref={videoRef} muted playsinline class="ssub__video" />
          <div class="ssub__reticle" aria-hidden="true" />
        </div>
      )}
      <button
        type="button"
        class={`ssub__row${scanning ? ' is-on' : ''}`}
        onClick={() => (scanning ? stopScan() : startScan())}
      >
        <span class="ssub__icon">
          <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">
            <path d="M3 7h4l2-3h6l2 3h4v12H3z" />
            <circle cx="12" cy="13" r="4" />
          </svg>
        </span>
        <span class="ssub__label">
          {error ? error : detected ? `זוהה: ${detected}` : scanning ? 'מחפש... עצור' : 'הפעל מצלמה'}
        </span>
      </button>
    </div>
  );
}
