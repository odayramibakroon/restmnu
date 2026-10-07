// Original, sample-free instrumental advertisement bed.
// Reproduce with: node output/restaurant-ad/make-music.cjs
const fs = require('fs');
const path = require('path');
const SR = 44100;
const DURATION = 62;
const bpm = 100;
const beat = 60 / bpm;
const bar = beat * 4;
const signal = new Float64Array(Math.ceil(SR * DURATION));
let seed = 19873451;
const noise = () => {
  seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0;
  return (seed / 4294967296) * 2 - 1;
};
const hz = midi => 440 * Math.pow(2, (midi - 69) / 12);
const tau = 2 * Math.PI;
function place(start, seconds, synth) {
  const first = Math.round(start * SR);
  const count = Math.ceil(seconds * SR);
  for (let i = 0; i < count && first + i < signal.length; i++) {
    if (first + i >= 0) signal[first + i] += synth(i / SR, i);
  }
}
function mallet(time, note, amp, length = 1.65) {
  const f = hz(note);
  place(time, length, t => {
    const attack = 1 - Math.exp(-t * 240);
    const body = Math.sin(tau * f * t) * Math.exp(-t * 3.5);
    const partial = 0.22 * Math.sin(tau * f * 2 * t) * Math.exp(-t * 8);
    const bell = 0.09 * Math.sin(tau * f * 3.98 * t) * Math.exp(-t * 13);
    return amp * attack * (body + partial + bell) * Math.min(1, (length - t) * 18);
  });
  // Soft delayed reflections leave room for a centered voice.
  place(time + 0.165, length, t => amp * 0.095 * (1 - Math.exp(-t * 180)) *
    Math.sin(tau * f * t) * Math.exp(-t * 4.5) * Math.min(1, (length - t) * 18));
}
function bass(time, note, amp, length = 0.92) {
  const f = hz(note);
  place(time, length, t => {
    const env = (1 - Math.exp(-t * 85)) * Math.exp(-t * 2.5) * Math.min(1, (length - t) * 22);
    return amp * env * (Math.sin(tau * f * t) + 0.14 * Math.sin(tau * 2 * f * t));
  });
}
function warmChord(time, notes, amp, length = 2.8) {
  const frequencies = notes.map(hz);
  place(time, length, t => {
    const env = Math.min(1, t / 0.23) * Math.pow(Math.max(0, 1 - t / length), 1.4);
    let s = 0;
    for (let k = 0; k < frequencies.length; k++) {
      const f = frequencies[k];
      s += Math.sin(tau * f * t + k * 0.37) + 0.13 * Math.sin(tau * 2 * f * t);
    }
    return (amp / frequencies.length) * env * s;
  });
}
function kick(time, amp) {
  place(time, 0.27, t => amp * (1 - Math.exp(-t * 900)) * Math.exp(-t * 20) *
    Math.sin(tau * (46 * t + 39 * (1 - Math.exp(-t * 40)) / 40)));
}
function hat(time, amp) {
  let smooth = 0;
  let smooth2 = 0;
  place(time, 0.075, t => {
    const n = noise();
    smooth += 0.16 * (n - smooth);
    smooth2 += 0.6 * (n - smooth2);
    return amp * (smooth2 - smooth) * (1 - Math.exp(-t * 1200)) * Math.exp(-t * 65);
  });
}
function softTap(time, amp) {
  let low = 0;
  place(time, 0.15, t => {
    low += 0.1 * (noise() - low);
    return amp * (1 - Math.exp(-t * 900)) * Math.exp(-t * 38) *
      (0.6 * low + 0.16 * Math.sin(tau * 730 * t));
  });
}

// Cmaj7 / Am7 / Fmaj7 / G6: a deliberately light, friendly arrangement.
const progression = [
  { root: 36, chord: [60, 64, 67, 71], melody: [76, 79, 74, 76, 79] },
  { root: 33, chord: [57, 60, 64, 67], melody: [76, 72, 79, 76, 72] },
  { root: 29, chord: [57, 60, 64, 65], melody: [77, 76, 72, 76, 77] },
  { root: 31, chord: [55, 59, 62, 64], melody: [74, 79, 76, 74, 71] },
];
for (let b = 0; b < 24; b++) {
  const t = b * bar;
  const c = progression[Math.floor(b / 2) % progression.length];
  const hook = t < 12;
  const amount = hook ? 0.75 : 1;
  warmChord(t, c.chord, 0.047 * amount);
  bass(t, c.root, 0.105 * amount);
  bass(t + 2.5 * beat, c.root + (b % 2 ? 7 : 12), 0.06 * amount, 0.75);
  const offsets = hook ? [0.5, 2, 3.5] : [0.5, 1.25, 2, 2.75, 3.5];
  offsets.forEach((offset, i) => {
    const n = c.melody[(i + (b % 2 ? 2 : 0)) % c.melody.length];
    mallet(t + offset * beat, n, (i % 2 ? 0.046 : 0.062) * amount);
  });
  if (!hook) {
    kick(t, 0.095);
    kick(t + 2 * beat, 0.065);
    softTap(t + beat, 0.07);
    softTap(t + 3 * beat, 0.06);
    for (let s = 0; s < 8; s++) hat(t + s * beat / 2, s % 2 ? 0.018 : 0.026);
  } else {
    hat(t + 1.5 * beat, 0.011);
    hat(t + 3.5 * beat, 0.01);
  }
}
// Gentle final resolution and space under the contact details.
warmChord(57.6, [60, 64, 67, 71], 0.055, 4.3);
bass(57.6, 36, 0.09, 2.3);
mallet(57.8, 76, 0.047, 2.5);
mallet(58.1, 79, 0.046, 2.7);
mallet(58.4, 84, 0.043, 2.8);

function whoosh(at, amp = 0.041) {
  let low = 0;
  let wide = 0;
  const length = 0.62;
  place(at - 0.35, length, t => {
    const p = t / length;
    const n = noise();
    low += 0.018 * (n - low);
    wide += (0.05 + 0.25 * Math.sin(Math.PI * p)) * (n - wide);
    return amp * (wide - low) * Math.pow(Math.sin(Math.PI * p), 2.4);
  });
}
[12, 21, 25, 34, 44, 52, 60].forEach(t => whoosh(t));
mallet(31.05, 84, 0.047, 0.75);
mallet(31.22, 88, 0.038, 0.85);

let peak = 0;
for (let i = 0; i < signal.length; i++) {
  const t = i / SR;
  const fadeIn = Math.min(1, t / 0.55);
  const fadeOut = Math.min(1, Math.max(0, (DURATION - t) / 1.7));
  signal[i] = Math.tanh(signal[i] * 1.2) * fadeIn * fadeOut;
  peak = Math.max(peak, Math.abs(signal[i]));
}
const gain = 0.4 / peak;
const bytes = signal.length * 2;
const wav = Buffer.alloc(44 + bytes);
wav.write('RIFF', 0); wav.writeUInt32LE(36 + bytes, 4); wav.write('WAVE', 8);
wav.write('fmt ', 12); wav.writeUInt32LE(16, 16); wav.writeUInt16LE(1, 20);
wav.writeUInt16LE(1, 22); wav.writeUInt32LE(SR, 24); wav.writeUInt32LE(SR * 2, 28);
wav.writeUInt16LE(2, 32); wav.writeUInt16LE(16, 34); wav.write('data', 36);
wav.writeUInt32LE(bytes, 40);
let squares = 0;
for (let i = 0; i < signal.length; i++) {
  const sample = signal[i] * gain;
  squares += sample * sample;
  wav.writeInt16LE(Math.round(sample * 32767), 44 + i * 2);
}
const out = path.join(__dirname, 'music-bed.wav');
fs.writeFileSync(out, wav);
console.log(JSON.stringify({ file: out, duration: DURATION, sampleRate: SR,
  peakDbFS: 20 * Math.log10(0.4), rmsDbFS: 20 * Math.log10(Math.sqrt(squares / signal.length)),
  recommendedMixGainDb: -7, originalComposition: true }, null, 2));
