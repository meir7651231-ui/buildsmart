/**
 * BarcodeDetector wrapper. Chromium-based browsers support this natively;
 * Safari and Firefox do not. Callers should check `isBarcodeSupported()`.
 */

type Detected = { rawValue: string; format: string };

type BarcodeDetector = {
  detect: (source: CanvasImageSource | ImageBitmap | HTMLVideoElement) => Promise<Detected[]>;
};

type BarcodeDetectorCtor = new (opts?: { formats?: string[] }) => BarcodeDetector;

function getCtor(): BarcodeDetectorCtor | null {
  return (window as unknown as { BarcodeDetector?: BarcodeDetectorCtor }).BarcodeDetector ?? null;
}

export function isBarcodeSupported(): boolean {
  return getCtor() !== null && !!navigator.mediaDevices?.getUserMedia;
}

export type BarcodeSession = {
  video: HTMLVideoElement;
  stop: () => void;
};

export async function startBarcodeScanner(
  videoEl: HTMLVideoElement,
  onDetect: (value: string) => void,
  onError: (msg: string) => void,
): Promise<BarcodeSession | null> {
  const Ctor = getCtor();
  if (!Ctor) {
    onError('הדפדפן הזה לא תומך בסריקת ברקוד');
    return null;
  }
  const detector = new Ctor({
    formats: ['ean_13', 'ean_8', 'code_128', 'code_39', 'qr_code'],
  });

  let stream: MediaStream | null = null;
  try {
    stream = await navigator.mediaDevices.getUserMedia({
      video: { facingMode: { ideal: 'environment' } },
      audio: false,
    });
  } catch (err) {
    onError('אין גישה למצלמה');
    return null;
  }

  videoEl.srcObject = stream;
  videoEl.setAttribute('playsinline', 'true');
  await videoEl.play();

  let running = true;
  let raf = 0;

  const tick = async () => {
    if (!running) return;
    try {
      const found = await detector.detect(videoEl);
      if (found.length > 0) {
        onDetect(found[0]!.rawValue);
        return;
      }
    } catch {
      /* transient detect error — keep scanning */
    }
    raf = requestAnimationFrame(tick);
  };
  raf = requestAnimationFrame(tick);

  const stop = () => {
    running = false;
    cancelAnimationFrame(raf);
    videoEl.srcObject = null;
    stream?.getTracks().forEach((t) => t.stop());
  };

  return { video: videoEl, stop };
}
