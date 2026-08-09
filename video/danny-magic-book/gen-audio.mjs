// Procedural soundtrack: magical music-box piano + twinkle SFX + page flips + whooshes.
// Writes audio.wav (44.1kHz, 16-bit stereo, 12s). Fully deterministic.
import fs from 'node:fs';

const SR = 44100, DUR = 12, N = SR * DUR;
const L = new Float64Array(N), R = new Float64Array(N);

function mulberry32(a){return function(){a|=0;a=a+0x6D2B79F5|0;let t=Math.imul(a^a>>>15,1|a);t=t+Math.imul(t^t>>>7,61|t)^t;return((t^t>>>14)>>>0)/4294967296}}
const rng = mulberry32(20260809);

// note frequencies (A major pentatonic-ish palette)
const F = {A2:110, E3:164.81, Fs3:185, A3:220, B3:246.94, Cs4:277.18, E4:329.63, Fs4:369.99,
  A4:440, B4:493.88, Cs5:554.37, E5:659.26, Fs5:739.99, A5:880, B5:987.77, Cs6:1108.73, E6:1318.5};

// music-box piano: additive partials, fast attack, exp decay
function note(t0, f, dur, amp, pan = 0) {
  const s0 = Math.floor(t0 * SR), det = 1 + (rng() - .5) * .0015;
  const partials = [[1, 1], [2, .45], [3, .2], [4.2, .07]];
  const tau = dur * .45;
  const gL = amp * Math.min(1, 1 - pan), gR = amp * Math.min(1, 1 + pan);
  const len = Math.min(N - s0, Math.floor(dur * SR));
  for (let i = 0; i < len; i++) {
    const t = i / SR;
    const env = Math.min(t / .006, 1) * Math.exp(-t / tau);
    let v = 0;
    for (const [h, a] of partials) v += a * Math.sin(2 * Math.PI * f * det * h * t);
    v *= env * .22;
    L[s0 + i] += v * gL; R[s0 + i] += v * gR;
  }
}
// bell twinkle: inharmonic shimmer
function twinkle(t0, f, amp, pan = 0) {
  const s0 = Math.floor(t0 * SR), len = Math.min(N - s0, Math.floor(.5 * SR));
  const gL = amp * (1 - pan), gR = amp * (1 + pan);
  for (let i = 0; i < len; i++) {
    const t = i / SR;
    const env = Math.min(t / .003, 1) * Math.exp(-t / .12);
    const v = (Math.sin(2 * Math.PI * f * t) + .6 * Math.sin(2 * Math.PI * f * 2.76 * t)) * env * .1;
    L[s0 + i] += v * gL; R[s0 + i] += v * gR;
  }
}
// filtered noise (page flips / whoosh)
function noiseBurst(t0, dur, amp, lp, hp, sweep = 0) {
  const s0 = Math.floor(t0 * SR), len = Math.min(N - s0, Math.floor(dur * SR));
  let lo = 0, lo2 = 0;
  for (let i = 0; i < len; i++) {
    const t = i / len;
    const env = Math.sin(Math.PI * Math.min(1, t * (1 + sweep))) ** 2;
    const w = (rng() * 2 - 1);
    const a1 = Math.min(.99, lp + sweep * t * .3);
    lo += (w - lo) * (1 - a1);            // lowpass
    lo2 += (lo - lo2) * (1 - hp);         // second stage
    const band = lo - lo2;                // bandpass-ish
    const v = band * env * amp;
    L[s0 + i] += v * (1 - .2); R[s0 + i] += v * (1 + .2) * .9;
  }
}

/* ---------------- arrangement ---------------- */
// 0-3s: sparse mysterious intro
note(0.15, F.A3, 2.2, .5, -.2);
note(0.9,  F.E4, 1.8, .38, .2);
note(1.7,  F.Cs4, 1.6, .4, -.1);
note(2.35, F.B3, 1.4, .34, .15);
note(2.9,  F.A2, 2.2, .4, 0);

// 3.05: the book is found — first twinkle gliss
[F.E5, F.Fs5, F.A5, F.B5, F.Cs6].forEach((f, i) => twinkle(3.05 + i * .07, f, .5 - i * .05, (i - 2) * .2));
noiseBurst(2.85, .7, .35, .12, .95, 1.2);          // whoosh: pulling the book out

// 3.2-5.6: gentle arpeggio (music box)
const arp = [F.A3, F.E4, F.A4, F.Cs5, F.E5, F.Cs5, F.A4, F.E4];
for (let k = 0; k < 8; k++) note(3.3 + k * .29, arp[k], .8, .3, ((k % 4) - 1.5) * .15);
const arp2 = [F.Fs3, F.Cs4, F.Fs4, F.A4, F.Cs5, F.A4, F.Fs4, F.Cs4];
for (let k = 0; k < 8; k++) note(5.62 + k * .29, arp2[k], .8, .3, ((k % 4) - 1.5) * .15);

// 5.7: book opens — rising magic + soft whoosh
noiseBurst(5.6, .9, .28, .1, .96, 1.5);
[F.A4, F.B4, F.Cs5, F.E5].forEach((f, i) => note(5.75 + i * .16, f, 1.0, .3, (i - 1.5) * .15));

// 7.0-8.6: pages flip by themselves — flutter + playful melody
for (let i = 0; i < 5; i++) noiseBurst(7.0 + i * .38, .13, .5, .35, .8);
const mel = [[7.05, F.E5, .5], [7.43, F.Cs5, .5], [7.81, F.B4, .5], [8.19, F.Cs5, .5], [8.45, F.E5, .7]];
for (const [t, f, d] of mel) note(t, f, d, .34, .1);
note(7.0, F.A2, 1.8, .35, 0); note(8.0, F.E3, 1.6, .3, 0);

// 8.75: "BE WISE" appears — cascade + big warm chord
noiseBurst(8.55, .8, .3, .08, .97, 2);
for (let i = 0; i < 10; i++) {
  const scale = [F.A5, F.B5, F.Cs6, F.E6, F.E5, F.Fs5];
  twinkle(8.8 + i * .09, scale[Math.floor(rng() * scale.length)], .42 - i * .03, (rng() - .5) * .8);
}
[[F.A2, .5], [F.E4, .4], [F.A4, .42], [F.Cs5, .4], [F.E5, .34], [F.B4, .3]].forEach(([f, a], i) =>
  note(8.85 + i * .04, f, 2.8, a, (i - 2.5) * .12));

// 9.8-12: resolution — soft descending answer + final chord halo
note(9.9,  F.Cs5, 1.0, .3, .2);
note(10.35, F.B4, 1.0, .28, -.15);
note(10.8, F.A4, 2.2, .34, 0);
[[F.A2, .4], [F.E3, .3], [F.A3, .32], [F.Cs4, .28], [F.E4, .26]].forEach(([f, a], i) =>
  note(10.85 + i * .05, f, 2.4, a, (i - 2) * .1));
for (let i = 0; i < 6; i++) twinkle(10.2 + i * .28, [F.A5, F.Cs6, F.E5, F.B5][i % 4], .2, (rng() - .5) * .6);

/* ---------------- master ---------------- */
const out = Buffer.alloc(44 + N * 4);
out.write('RIFF', 0); out.writeUInt32LE(36 + N * 4, 4); out.write('WAVE', 8);
out.write('fmt ', 12); out.writeUInt32LE(16, 16); out.writeUInt16LE(1, 20); out.writeUInt16LE(2, 22);
out.writeUInt32LE(SR, 24); out.writeUInt32LE(SR * 4, 28); out.writeUInt16LE(4, 32); out.writeUInt16LE(16, 34);
out.write('data', 36); out.writeUInt32LE(N * 4, 40);
for (let i = 0; i < N; i++) {
  const t = i / SR;
  let g = Math.min(t / .05, 1);                          // fade in
  if (t > DUR - 1.0) g *= (DUR - t) / 1.0;               // fade out
  const l = Math.tanh(L[i] * 1.4) * .92 * g, r = Math.tanh(R[i] * 1.4) * .92 * g;
  out.writeInt16LE(Math.round(l * 32767), 44 + i * 4);
  out.writeInt16LE(Math.round(r * 32767), 46 + i * 4);
}
fs.writeFileSync(new URL('./audio.wav', import.meta.url), out);
console.log('audio.wav written:', (out.length / 1024).toFixed(0), 'KB');
