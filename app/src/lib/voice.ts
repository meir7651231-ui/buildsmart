/**
 * Thin wrapper over the Web Speech API. Hebrew-first (he-IL).
 *
 * Browser support is patchy — Chrome/Edge/Safari on macOS/iOS support it,
 * Firefox does not. Callers should check `isVoiceSupported()` first.
 */

type SpeechRec = {
  lang: string;
  continuous: boolean;
  interimResults: boolean;
  onresult: ((e: any) => void) | null;
  onend: (() => void) | null;
  onerror: ((e: any) => void) | null;
  start: () => void;
  stop: () => void;
  abort: () => void;
};

type SpeechRecCtor = new () => SpeechRec;

function getCtor(): SpeechRecCtor | null {
  const w = window as unknown as {
    SpeechRecognition?: SpeechRecCtor;
    webkitSpeechRecognition?: SpeechRecCtor;
  };
  return w.SpeechRecognition ?? w.webkitSpeechRecognition ?? null;
}

export function isVoiceSupported(): boolean {
  return getCtor() !== null;
}

export type VoiceHandlers = {
  onTranscript: (text: string, isFinal: boolean) => void;
  onEnd: () => void;
  onError: (msg: string) => void;
};

export function startVoiceRecognition(h: VoiceHandlers): { stop: () => void } | null {
  const Ctor = getCtor();
  if (!Ctor) {
    h.onError('הדפדפן הזה לא תומך בחיפוש קולי');
    h.onEnd();
    return null;
  }
  const rec = new Ctor();
  rec.lang = 'he-IL';
  rec.continuous = false;
  rec.interimResults = true;

  rec.onresult = (e: any) => {
    let text = '';
    let isFinal = false;
    for (let i = 0; i < e.results.length; i++) {
      const r = e.results[i];
      text += r[0].transcript;
      if (r.isFinal) isFinal = true;
    }
    h.onTranscript(text.trim(), isFinal);
  };
  rec.onerror = (e: any) => {
    h.onError(e?.error ?? 'שגיאה');
  };
  rec.onend = () => h.onEnd();

  try {
    rec.start();
  } catch (err) {
    h.onError(err instanceof Error ? err.message : String(err));
    h.onEnd();
    return null;
  }
  return { stop: () => rec.stop() };
}
