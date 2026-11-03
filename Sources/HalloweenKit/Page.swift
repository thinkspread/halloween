// Copyright (c) 2026 Jiejing Zhang.
//
// The one page: the camera full screen, a Start button, a status line, and
// two skeletons -- a cute one for children and pets, a scary one for
// adults.  It is one string in the binary so `brew install` installs one
// file, and it talks only to the server that served it (connect-src 'self'),
// which hands its three calls on to tempo9 (Proxy.swift).

public enum Page {
    /// Reach this origin and nothing else.  `worker-src blob:` is the 1 s
    /// tick (a hidden tab throttles main-thread timers; a worker's are not).
    public static let contentSecurityPolicy =
        "default-src 'none'; script-src 'unsafe-inline'; "
        + "style-src 'unsafe-inline'; img-src data: blob:; "
        + "media-src blob: mediastream:; connect-src 'self'; "
        + "worker-src blob:; base-uri 'none'; form-action 'none'; "
        + "frame-ancestors 'none'"

    public static let html = #"""
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>🎃 Halloween mode</title>
<style>
* { box-sizing: border-box; }
html, body { margin: 0; height: 100%; background: #000; color: #fff; overflow: hidden;
             font: 16px/1.4 -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; }
video { position: fixed; inset: 0; width: 100%; height: 100%; object-fit: cover;
        transform: scaleX(-1); background: #000; }
.go { position: fixed; left: 50%; top: 50%; transform: translate(-50%, -50%); cursor: pointer;
      font: 700 clamp(28px, 5vw, 60px)/1 -apple-system, BlinkMacSystemFont, sans-serif;
      padding: .55em 1.3em; border: 0; border-radius: 999px; background: #ff7a00; color: #140a00; }
.go:disabled { opacity: .6; cursor: default; }
.lang { position: fixed; top: 16px; right: 16px; cursor: pointer; font: 600 15px/1 -apple-system, sans-serif;
        padding: 8px 14px; border-radius: 999px; border: 1px solid #fff6; background: #0006; color: #fff; }
.state { position: fixed; left: 0; right: 0; bottom: 5vh; padding: 0 5vw; text-align: center;
         text-shadow: 0 1px 10px #000;
         font: 600 clamp(17px, 2.6vw, 30px)/1.35 -apple-system, BlinkMacSystemFont, sans-serif; }
.hide { display: none !important; }
body:has(#boo:not(.hide)) .state { visibility: hidden; }   /* the caption speaks then */
/* Halloween mode: the skeleton that jumps out when someone walks in --
   a scary one (#booScary, lunging, a red flash) or a cute one (#booCute,
   hopping and waving a lollipop), by the rule's action. */
.boo { position: fixed; inset: 0; z-index: 10; display: grid; place-items: center;
       background: radial-gradient(circle, rgba(20,40,10,.92), rgba(0,0,0,.97)); cursor: pointer; }
.boo svg { height: min(80vh, 120vw); width: auto; filter: drop-shadow(0 0 18px #8f6);
           animation: pop .22s ease-out, bob .38s ease-in-out .22s infinite alternate; }
.boo .bone { fill: #f4f1e8; stroke: #f4f1e8; stroke-linecap: round; }
.boo .eye { fill: #ff3b1f; animation: flicker .18s steps(2) infinite; }
.boo #armL { transform-origin: 72px 96px; animation: waveL .26s ease-in-out infinite alternate; }
.boo #armR { transform-origin: 128px 96px; animation: waveR .26s ease-in-out infinite alternate; }
.boo #legL { transform-origin: 90px 200px; animation: kickL .3s ease-in-out infinite alternate; }
.boo #legR { transform-origin: 110px 200px; animation: kickR .3s ease-in-out infinite alternate; }
.boo #jaw { animation: chatter .12s ease-in-out infinite alternate; }
@keyframes pop { from { transform: scale(.15) rotate(-20deg); opacity: 0; } to { transform: scale(1); opacity: 1; } }
@keyframes bob { from { transform: translateY(0) rotate(-3deg); } to { transform: translateY(-5%) rotate(3deg); } }
@keyframes waveL { from { transform: rotate(25deg); } to { transform: rotate(-70deg); } }
@keyframes waveR { from { transform: rotate(-25deg); } to { transform: rotate(70deg); } }
@keyframes kickL { from { transform: rotate(18deg); } to { transform: rotate(-12deg); } }
@keyframes kickR { from { transform: rotate(-12deg); } to { transform: rotate(18deg); } }
@keyframes chatter { from { transform: translateY(0); } to { transform: translateY(7px); } }
@keyframes flicker { to { opacity: .35; } }
.boo #booCute { display: none; }
.boo.cute #booCute { display: block; }
.boo.cute #booScary { display: none; }
.boo.scary svg { animation: lunge .4s cubic-bezier(.2, 1.5, .4, 1), bob .38s ease-in-out .4s infinite alternate; }
.boo.scary::before { content: ""; position: absolute; inset: 0; background: #b00000; pointer-events: none;
                     animation: flash .5s ease-out forwards; }
@keyframes lunge { from { transform: scale(.08); opacity: 0; } 70% { transform: scale(1.18); opacity: 1; }
                   to { transform: scale(1); } }
@keyframes flash { from { opacity: .85; } to { opacity: 0; } }
.boo.cute { background: radial-gradient(circle, rgba(118,56,160,.92), rgba(28,8,44,.97)); }
.boo.cute svg { filter: drop-shadow(0 0 22px #ff9bd2);
                animation: popCute .55s cubic-bezier(.3, 1.6, .5, 1), hop .42s ease-in-out .55s infinite alternate; }
.boo.cute .bone { fill: #fbf7ee; stroke: #fbf7ee; }
.boo #cArmL { transform-origin: 78px 164px; animation: hello .3s ease-in-out infinite alternate; }
.boo #cPop { transform-origin: 160px 196px; animation: wiggle .5s ease-in-out infinite alternate; }
.boo #cBow { transform-origin: 128px 36px; animation: wiggle .4s ease-in-out infinite alternate; }
.boo #cEyes { transform-origin: 100px 86px; animation: blink 2.6s infinite; }
@keyframes popCute { from { transform: scale(.2) translateY(30%); opacity: 0; } to { transform: scale(1); opacity: 1; } }
@keyframes hop { from { transform: translateY(0); } to { transform: translateY(-6%); } }
@keyframes hello { from { transform: rotate(-28deg); } to { transform: rotate(22deg); } }
@keyframes wiggle { from { transform: rotate(-8deg); } to { transform: rotate(8deg); } }
@keyframes blink { 0%, 90%, 100% { transform: scaleY(1); } 95% { transform: scaleY(.1); } }
.boo.cute .caption { text-shadow: 0 0 14px #ff9bd2; }
.boo .caption { position: absolute; left: 0; right: 0; bottom: 7vh; padding: 0 5vw; text-align: center;
                color: #fff; text-shadow: 0 0 14px #8f6;
                font: 700 clamp(22px, 4vw, 46px)/1.25 -apple-system, BlinkMacSystemFont, sans-serif; }
</style>
</head>
<body>
<video id="vid" muted playsinline autoplay></video>
<button class="go" id="go">🎃 Start</button>
<button class="lang" id="lang">中文</button>
<div class="state" id="state"></div>
<div class="boo hide" id="boo">
  <svg id="booScary" viewBox="0 0 200 300" aria-label="skeleton">
    <g class="bone">
      <ellipse cx="100" cy="44" rx="31" ry="33"/>
      <g id="jaw"><rect x="80" y="66" width="40" height="16" rx="6"/>
        <path d="M86 70 v10 M93 70 v10 M100 70 v10 M107 70 v10 M114 70 v10" stroke="#111" stroke-width="2"/></g>
      <line x1="100" y1="78" x2="100" y2="196" stroke-width="7"/>
      <path d="M100 100 q-30 3 -33 17 M100 116 q-28 3 -31 16 M100 132 q-25 3 -28 14 M100 148 q-21 3 -24 12
               M100 100 q30 3 33 17 M100 116 q28 3 31 16 M100 132 q25 3 28 14 M100 148 q21 3 24 12"
            fill="none" stroke-width="5"/>
      <line x1="70" y1="94" x2="130" y2="94" stroke-width="6"/>
      <ellipse cx="100" cy="200" rx="22" ry="10"/>
      <g id="armL"><polyline points="72,96 46,140 40,182" fill="none" stroke-width="6"/><circle cx="40" cy="186" r="7"/></g>
      <g id="armR"><polyline points="128,96 154,140 160,182" fill="none" stroke-width="6"/><circle cx="160" cy="186" r="7"/></g>
      <g id="legL"><polyline points="90,204 78,252 74,292" fill="none" stroke-width="7"/><ellipse cx="66" cy="294" rx="11" ry="5"/></g>
      <g id="legR"><polyline points="110,204 122,252 126,292" fill="none" stroke-width="7"/><ellipse cx="134" cy="294" rx="11" ry="5"/></g>
    </g>
    <circle class="eye" cx="88" cy="42" r="9"/><circle class="eye" cx="112" cy="42" r="9"/>
    <path d="M96 56 L100 49 L104 56 Z" fill="#111"/>
  </svg>
  <svg id="booCute" viewBox="0 0 200 300" aria-label="cute skeleton">
    <g id="cPop">
      <line x1="160" y1="196" x2="172" y2="152" stroke="#fbf7ee" stroke-width="4" stroke-linecap="round"/>
      <circle cx="174" cy="140" r="16" fill="#ff7ab8"/>
      <path d="M174 140 m-9 0 a9 9 0 1 1 9 9 a5 5 0 1 1 -5 -5" fill="none" stroke="#fff" stroke-width="3"/>
    </g>
    <g class="bone">
      <line x1="90" y1="236" x2="84" y2="268" stroke-width="9"/><ellipse cx="80" cy="274" rx="13" ry="8"/>
      <line x1="110" y1="236" x2="116" y2="268" stroke-width="9"/><ellipse cx="120" cy="274" rx="13" ry="8"/>
      <ellipse cx="100" cy="234" rx="20" ry="11"/>
      <line x1="100" y1="148" x2="100" y2="232" stroke-width="8"/>
      <path d="M100 174 q-22 2 -24 12 M100 190 q-20 2 -22 11 M100 174 q22 2 24 12 M100 190 q20 2 22 11"
            fill="none" stroke-width="6"/>
      <line x1="76" y1="164" x2="124" y2="164" stroke-width="7"/>
      <g id="cArmL"><polyline points="78,164 44,150 26,122" fill="none" stroke-width="7"/><circle cx="24" cy="116" r="8"/></g>
      <polyline points="122,164 146,182 158,194" fill="none" stroke-width="7"/><circle cx="160" cy="198" r="8"/>
      <circle cx="100" cy="88" r="62"/>
    </g>
    <g id="cBow" fill="#ff7a00"><path d="M128 36 l-18 -12 v24 Z M128 36 l18 -12 v24 Z"/><circle cx="128" cy="36" r="6"/></g>
    <g id="cEyes">
      <ellipse cx="78" cy="86" rx="15" ry="18" fill="#1b1222"/><ellipse cx="122" cy="86" rx="15" ry="18" fill="#1b1222"/>
      <circle cx="84" cy="79" r="5.5" fill="#fff"/><circle cx="128" cy="79" r="5.5" fill="#fff"/>
      <circle cx="74" cy="94" r="2.5" fill="#fff"/><circle cx="118" cy="94" r="2.5" fill="#fff"/>
    </g>
    <ellipse cx="62" cy="112" rx="11" ry="6.5" fill="#ff8fb8" opacity=".75"/>
    <ellipse cx="138" cy="112" rx="11" ry="6.5" fill="#ff8fb8" opacity=".75"/>
    <path d="M96 106 q4 -5 8 0 q-4 5 -8 0 Z" fill="#1b1222"/>
    <path d="M84 120 q16 16 32 0" fill="none" stroke="#1b1222" stroke-width="4" stroke-linecap="round"/>
  </svg>
  <div class="caption" id="booLine"></div>
</div>
<script>
"use strict";
const $ = (id) => document.getElementById(id);
const vid = $("vid");
let model = null, audio = null, running = false, busy = false, lastMatch = 0;

// English or Chinese: the browser's language unless the viewer picked one
// with the button, which is shown only before Start (it stays out of any
// recording).  Everything said, shown and asked comes in both.
const STR = {
  en: { title: "🎃 Halloween mode", start: "🎃 Start", other: "中文",
        hint: "Press Start. Whoever the camera sees gets a skeleton. Everything runs on this Mac.",
        waiting: "👀 Waiting for someone to walk in…",
        seen: "Sees “{rule}” — step out of view and walk back in for another",
        noModel: "The model did not answer: ", noTower: "The vision encoder did not answer: ",
        down: "tempo9 is not answering. Is halloween still running in the terminal?",
        camera: "Camera: ", voice: "en-US" },
  zh: { title: "🎃 万圣节模式", start: "🎃 开始", other: "EN",
        hint: "点开始。摄像头里有人，骷髅就会跳出来。全部在这台 Mac 上运行。",
        waiting: "👀 等人走进来…",
        seen: "看到了「{rule}」——走出画面再进来，还会再吓一次",
        noModel: "模型没有回应：", noTower: "视觉编码器没有回应：",
        down: "tempo9 没有回应。终端里的 halloween 还在运行吗？",
        camera: "摄像头：", voice: "zh-CN" },
};
// What the model is asked, in order: it answers with the number of the
// first condition that holds, or 0, so the specific ones come first.
// Children and pets get the cute skeleton; adults get the one that lunges.
const RULES = {
  en: [
    { when: "a child wearing a Halloween costume", say: "Trick or treat! Great costume. Take two candies.", kind: "cute" },
    { when: "a child", say: "Hi there! Happy Halloween, little one.", kind: "cute" },
    { when: "an adult wearing a costume", say: "Nice costume... but I am scarier. Happy Halloween!", kind: "scary" },
    { when: "an adult", say: "Boo! Got you. Happy Halloween!", kind: "scary" },
    { when: "a dog or a cat", say: "A furry visitor. No candy for you.", kind: "cute" } ],
  zh: [
    { when: "穿着万圣节服装的小孩", say: "不给糖就捣蛋！服装真棒，拿两颗糖吧。", kind: "cute" },
    { when: "小孩", say: "嗨！万圣节快乐，小朋友。", kind: "cute" },
    { when: "穿着奇装异服的大人", say: "打扮得不错……可我更吓人。万圣节快乐！", kind: "scary" },
    { when: "大人", say: "吓到了吧！万圣节快乐！", kind: "scary" },
    { when: "狗或猫", say: "毛茸茸的客人，没有糖给你哦。", kind: "cute" } ],
};
let lang = "";
try { lang = localStorage.getItem("halloween.lang") || ""; } catch (_) {}
if (!STR[lang]) lang = (navigator.language || "").toLowerCase().startsWith("zh") ? "zh" : "en";
const t = (k) => STR[lang][k];
const rules = () => RULES[lang];
function applyLang() {
  document.documentElement.lang = lang === "zh" ? "zh-CN" : "en";
  document.title = t("title"); $("go").textContent = t("start"); $("lang").textContent = t("other");
  if (!running) setState(t("hint"));
}
$("lang").onclick = () => {
  lang = lang === "zh" ? "en" : "zh";
  try { localStorage.setItem("halloween.lang", lang); } catch (_) {}
  applyLang();
};

function setState(s) { $("state").textContent = s; }
function status() {
  const r = lastMatch && rules()[lastMatch - 1];
  setState(r ? t("seen").replace("{rule}", r.when) : t("waiting"));
}
applyLang();

// ---------- frames ----------
function frameToJpeg(src, maxSide, quality) {
  const w = src.videoWidth, h = src.videoHeight;
  const k = Math.min(1, maxSide / Math.max(w, h));
  const c = document.createElement("canvas");
  c.width = Math.max(1, Math.round(w * k)); c.height = Math.max(1, Math.round(h * k));
  c.getContext("2d").drawImage(src, 0, 0, c.width, c.height);
  return c.toDataURL("image/jpeg", quality);
}
function tinyGray(src) {
  const c = tinyGray.c || (tinyGray.c = Object.assign(document.createElement("canvas"), { width: 32, height: 18 }));
  const x = c.getContext("2d", { willReadFrequently: true });
  x.drawImage(src, 0, 0, 32, 18);
  const d = x.getImageData(0, 0, 32, 18).data, g = new Float32Array(576);
  for (let i = 0; i < 576; i++) g[i] = (d[4 * i] * .299 + d[4 * i + 1] * .587 + d[4 * i + 2] * .114) / 255;
  return g;
}
function meanAbs(a, b) { let s = 0; for (let i = 0; i < a.length; i++) s += Math.abs(a[i] - b[i]); return s / a.length; }
function f32(b64) {
  const s = atob(b64), u = new Uint8Array(s.length);
  for (let i = 0; i < s.length; i++) u[i] = s.charCodeAt(i);
  return new Float32Array(u.buffer);
}
function dist(a, b) { let s = 0; for (let i = 0; i < a.length; i++) s += a[i] * b[i]; return 1 - s; }
// The region that changed most when both frames carry regions, else the
// whole-frame vectors.
function gdist(a, b) {
  if (a.r && b.r && a.r.length === b.r.length) {
    let m = 0; for (let i = 0; i < a.r.length; i++) m = Math.max(m, dist(a.r[i], b.r[i]));
    return m;
  }
  return dist(a.g, b.g);
}
// tempo9's vision encoder only, never the language model: one unit vector
// for the frame and one for each of 12 regions.
async function towerFrame() {
  const r = await fetch("/v1/vision/frame", { method: "POST",
    headers: { "content-type": "application/json" }, body: JSON.stringify({ image: frameToJpeg(vid, 640, 0.7) }) });
  const j = await r.json();
  if (!r.ok) throw new Error((j.error && j.error.message) || r.status);
  const g = f32(j.embedding_f32), dim = j.dim || g.length;
  let regs = null;
  if (j.regions_f32) {
    const all = f32(j.regions_f32); regs = [];
    for (let i = 0; i + dim <= all.length; i += dim) regs.push(all.subarray(i, i + dim));
  }
  return { g, r: regs };
}
async function askModel(imageURL, text, maxTokens) {
  const r = await fetch("/v1/chat/completions", { method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ model, stream: false, temperature: 0, top_k: 1, max_tokens: maxTokens,
      chat_template_kwargs: { enable_thinking: false },
      messages: [{ role: "user", content: [
        { type: "image_url", image_url: { url: imageURL } }, { type: "text", text }] }] }) });
  const j = await r.json();
  if (!r.ok) throw new Error((j.error && (j.error.message || j.error)) || r.status);
  return (j.choices && j.choices[0] && j.choices[0].message && j.choices[0].message.content) || "";
}

// ---------- the scare ----------
// Synthesised, so the page still loads nothing.
function env(g, at, peak, end) {
  g.gain.setValueAtTime(0.0001, at);
  g.gain.exponentialRampToValueAtTime(peak, at + 0.03);
  g.gain.exponentialRampToValueAtTime(0.0001, end);
}
// Scary: a hiss of noise as it lunges, a falling ghost whistle, a low thud
// under it, and a cackle of short square-wave barks.
function spookySound() {
  if (!audio) return;
  const t0 = audio.currentTime, out = audio.destination;
  const buf = audio.createBuffer(1, Math.round(audio.sampleRate * 0.6), audio.sampleRate);
  const nd = buf.getChannelData(0);
  for (let i = 0; i < nd.length; i++) nd[i] = Math.random() * 2 - 1;
  const n = audio.createBufferSource(), nf = audio.createBiquadFilter(), ng = audio.createGain();
  n.buffer = buf; nf.type = "bandpass"; nf.frequency.value = 1500; nf.Q.value = 0.7;
  env(ng, t0, 0.45, t0 + 0.55); n.connect(nf); nf.connect(ng); ng.connect(out); n.start(t0);
  const o = audio.createOscillator(), og = audio.createGain();
  const lfo = audio.createOscillator(), lg = audio.createGain();
  o.frequency.setValueAtTime(950, t0); o.frequency.exponentialRampToValueAtTime(170, t0 + 1.7);
  lfo.frequency.value = 7; lg.gain.value = 45; lfo.connect(lg); lg.connect(o.frequency);
  env(og, t0, 0.3, t0 + 1.9); o.connect(og); og.connect(out);
  o.start(t0); lfo.start(t0); o.stop(t0 + 2); lfo.stop(t0 + 2);
  const d = audio.createOscillator(), dg = audio.createGain();
  d.type = "sawtooth"; d.frequency.setValueAtTime(75, t0); d.frequency.exponentialRampToValueAtTime(38, t0 + 1.3);
  env(dg, t0, 0.28, t0 + 1.5); d.connect(dg); dg.connect(out); d.start(t0); d.stop(t0 + 1.6);
  for (let i = 0; i < 7; i++) {
    const c = audio.createOscillator(), cg = audio.createGain(), at = t0 + 1.1 + i * 0.15;
    c.type = "square"; c.frequency.setValueAtTime(440 - i * 22, at);
    env(cg, at, 0.12, at + 0.11); c.connect(cg); cg.connect(out); c.start(at); c.stop(at + 0.13);
  }
}
// Cute: a music-box arpeggio up the C major chord, then a boing.
function cuteSound() {
  if (!audio) return;
  const t0 = audio.currentTime, out = audio.destination;
  [523.25, 659.25, 783.99, 1046.5].forEach((f, i) => {
    const o = audio.createOscillator(), g = audio.createGain(), at = t0 + i * 0.11;
    o.type = "triangle"; o.frequency.value = f;
    env(g, at, 0.22, at + 0.35); o.connect(g); g.connect(out); o.start(at); o.stop(at + 0.4);
  });
  const b = audio.createOscillator(), bg = audio.createGain(), at = t0 + 0.5;
  b.frequency.setValueAtTime(220, at); b.frequency.exponentialRampToValueAtTime(880, at + 0.22);
  env(bg, at, 0.2, at + 0.42); b.connect(bg); bg.connect(out); b.start(at); b.stop(at + 0.45);
}
// The Mac's own voices: squeaky for the cute one, slow and low for the other.
function speak(line, delayMs, kind) {
  if (!line || !("speechSynthesis" in window)) return;
  const u = new SpeechSynthesisUtterance(line);
  u.lang = t("voice");
  if (kind === "cute") { u.pitch = 1.7; u.rate = 1.05; } else { u.pitch = 0.4; u.rate = 0.82; }
  setTimeout(() => speechSynthesis.speak(u), delayMs || 0);
}
// The line is also a caption: most people watch a clip of this muted.
function scare(line, kind) {
  const cute = kind === "cute";
  (cute ? cuteSound : spookySound)();
  $("boo").classList.toggle("cute", cute); $("boo").classList.toggle("scary", !cute);
  $("booLine").textContent = line;
  $("boo").classList.remove("hide");
  speak(line, cute ? 700 : 1300, kind);    // after the jingle; after the whistle
  clearTimeout(scare.t); scare.t = setTimeout(() => $("boo").classList.add("hide"), 6000);
}
$("boo").onclick = () => $("boo").classList.add("hide");

// ---------- the gate ----------
// Once a second: a 32x18 pixel check, then tempo9's encoder, then -- only
// when the picture moved -- the model.  Distances are the region that moved
// most; the thresholds follow the camera's own noise (fire at 3.5x a running
// average of quiet frame-to-frame distance, settle at 2x, clamped).  A
// server that sends no regions gets the whole-frame vector and fixed
// thresholds measured for it.
const G = { fire: 0.025, settle: 0.010, pixel: 0.004, rLo: 0.030, rHi: 0.060, sLo: 0.020, sHi: 0.040, n0: 0.012 };
const BACKSTOP = 60;
const W = { anchor: null, prev: null, pending: false, followUp: false, lastAsk: 0, tiny: null,
            towerAt: 0, dAnchor: 1, regional: false, noise: null };
const clamp = (x, lo, hi) => Math.min(hi, Math.max(lo, x));
function gates() {
  if (!W.regional) return { fire: G.fire, settle: G.settle };
  const n = W.noise == null ? G.n0 : W.noise;
  return { fire: clamp(3.5 * n, G.rLo, G.rHi), settle: clamp(2 * n, G.sLo, G.sHi) };
}

// Which rule holds now.  A rule acts when it becomes the answer, not for as
// long as it stays the answer: one scare per visitor, re-armed when a later
// look sees nobody.  The first look acts too.
async function check() {
  busy = true;
  const prompt = "You are keeping an eye on a live camera for the user.\nConditions:\n" +
    rules().map((r, i) => (i + 1) + ". " + r.when).join("\n") + "\n" +
    "Look at this frame. On the first line write only the number of the first condition " +
    "that is true in this frame, or 0 if none is. On the second line, one short sentence " +
    "saying what you see that decides it.";
  try {
    const text = await askModel(frameToJpeg(vid, 1440, 0.85), prompt, 80);
    const first = text.trim().split("\n").map((s) => s.trim()).filter(Boolean)[0] || "";
    let k = parseInt((first.match(/\d+/) || ["0"])[0], 10);
    if (!(k >= 1 && k <= rules().length)) k = 0;
    if (k && k !== lastMatch) scare(rules()[k - 1].say, rules()[k - 1].kind);
    lastMatch = k;
    status();
  } catch (e) {
    setState(t("noModel") + e.message);
  }
  W.lastAsk = performance.now() / 1000; W.pending = false;
  busy = false;
}

async function tick() {
  if (!running || busy || vid.readyState < 2) return;
  busy = true;
  const now = performance.now() / 1000;
  const { fire, settle } = gates();
  let dPrev;
  try {
    const thumb = tinyGray(vid);
    // Unchanged at 32x18 against the last frame the encoder saw: skip it.
    // But run the encoder at least every 10 s, and every 2 s while someone
    // is in view -- the last sliver of a visitor leaving is under the pixel
    // check, and until the encoder sees the empty doorway the next visitor
    // is "the same answer".
    const gap = lastMatch ? 2 : 10;
    if (W.tiny && meanAbs(thumb, W.tiny) < G.pixel && now - W.towerAt < gap) {
      dPrev = 0;
    } else {
      const v = await towerFrame();
      W.tiny = thumb; W.towerAt = now;
      if (v.r) W.regional = true;
      dPrev = W.prev ? gdist(W.prev, v) : 1;
      W.dAnchor = W.anchor ? gdist(W.anchor, v) : 1;
      if (W.prev && !W.pending && dPrev < fire)
        W.noise = W.noise == null ? dPrev : 0.9 * W.noise + 0.1 * dPrev;
      W.prev = v;
    }
  } catch (e) {
    setState(t("noTower") + e.message); busy = false; return;
  }
  busy = false;

  // The frame the model is about to see becomes the anchor.
  const rebase = () => { W.anchor = W.prev; W.dAnchor = 0; };
  if (!W.anchor) { rebase(); await check(); return; }
  if (W.dAnchor > fire) W.pending = true;
  // Asked at the first sign of change -- a scare that waits for its victim
  // to stand still is no scare.  That look can catch someone half out of
  // the frame, and the rest of their exit can measure under fire, so once
  // the picture comes to rest somewhere the model has not seen, look again.
  const rested = W.followUp && dPrev < settle && W.dAnchor > settle;
  if (W.pending) {
    rebase(); await check(); W.followUp = true;
  } else if (rested) {
    W.followUp = false; rebase(); await check();
  } else if (now - W.lastAsk >= BACKSTOP) {
    if (W.dAnchor >= (W.regional ? settle : 0.003)) { rebase(); await check(); }
    else W.lastAsk = now;
  }
}

// ---------- start ----------
// One button, because a browser opens the camera and plays sound only
// after a click.
async function hello() {
  try {
    const m = await (await fetch("/v1/models")).json();
    model = m.data[0].id;
  } catch (e) {
    setState(t("down"));
  }
}
hello();
$("go").onclick = async () => {
  $("go").disabled = true;
  if (!model) await hello();
  if (!model) { $("go").disabled = false; return; }
  try {
    vid.srcObject = await navigator.mediaDevices.getUserMedia({ video: { width: 1280 } });
    await vid.play();
  } catch (e) {
    setState(t("camera") + e.message); $("go").disabled = false; return;
  }
  audio = new AudioContext(); audio.resume();
  $("go").classList.add("hide"); $("lang").classList.add("hide");
  running = true; W.lastAsk = performance.now() / 1000;
  status();
  // A worker's timer keeps its 1 s pace in a background tab.
  const ticker = new Worker(URL.createObjectURL(new Blob(
    ["setInterval(() => postMessage(0), 1000)"], { type: "text/javascript" })));
  ticker.onmessage = () => tick();
};
</script>
</body>
</html>
"""#
}
