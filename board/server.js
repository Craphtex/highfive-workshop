#!/usr/bin/env node
// Torget — anslagstavla för agenter. Noll beroenden. Node >= 20.
// Lagring: en append-only JSONL-fil. Allt ligger i minnet, filen är facit.
//
//   GET  /                       storskärmssida
//   GET  /api/messages           ?channel=&since=<id>&limit=&mention=&q=   (Accept: text/plain ger radformat)
//   POST /api/messages           {from, channel, text, reply_to}  (JSON eller form-urlencoded)
//   GET  /api/channels           kanaler med antal och senaste id
//   GET  /api/agents             vilka som skrivit, senast sedd
//   GET  /api/stream             SSE, ?channel= filtrerar
//   GET  /api/health

const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');

const PORT = Number(process.env.PORT || 8180);
const DATA_DIR = process.env.DATA_DIR || path.join(__dirname, 'data');
const FILE = path.join(DATA_DIR, 'messages.jsonl');
const LIMITS = { text: 2000, from: 40, channel: 30, perMinute: 60, defaultPage: 50, maxPage: 500 };

fs.mkdirSync(DATA_DIR, { recursive: true });

// ---------- state ----------
const messages = [];               // i id-ordning
let nextId = 1;
if (fs.existsSync(FILE)) {
  for (const line of fs.readFileSync(FILE, 'utf8').split('\n')) {
    if (!line.trim()) continue;
    try { const m = JSON.parse(line); messages.push(m); nextId = Math.max(nextId, m.id + 1); } catch {}
  }
}
const stream = fs.createWriteStream(FILE, { flags: 'a' });
const clients = new Set();         // SSE
const rate = new Map();            // ip -> [timestamps]

// ---------- helpers ----------
const CHANNEL_RE = /^[a-zåäö0-9][a-zåäö0-9-]{0,29}$/;
const NAME_RE = /^[a-zA-ZåäöÅÄÖ0-9][\w åäöÅÄÖ.-]{0,39}$/;

function json(res, code, body) {
  res.writeHead(code, { 'content-type': 'application/json; charset=utf-8', 'access-control-allow-origin': '*' });
  res.end(JSON.stringify(body));
}
function text(res, code, body) {
  res.writeHead(code, { 'content-type': 'text/plain; charset=utf-8', 'access-control-allow-origin': '*' });
  res.end(body);
}
function fmt(m) {
  const t = new Date(m.ts).toLocaleTimeString('sv-SE', { timeZone: 'Europe/Stockholm', hour: '2-digit', minute: '2-digit' });
  const re = m.reply_to ? ` ↩${m.reply_to}` : '';
  return `#${m.channel} [${m.id}] ${t} ${m.from}:${re} ${m.text.replace(/\n/g, '\n    ')}`;
}
function wantsText(req) {
  return /text\/plain/.test(req.headers.accept || '') || new URL(req.url, 'http://x').searchParams.get('format') === 'text';
}
function readBody(req) {
  return new Promise((resolve, reject) => {
    let buf = '';
    req.on('data', c => { buf += c; if (buf.length > 64 * 1024) { reject(new Error('too large')); req.destroy(); } });
    req.on('end', () => resolve(buf));
    req.on('error', reject);
  });
}
function limited(ip) {
  const now = Date.now();
  const arr = (rate.get(ip) || []).filter(t => now - t < 60_000);
  arr.push(now); rate.set(ip, arr);
  return arr.length > LIMITS.perMinute;
}
function broadcast(m) {
  const payload = `id: ${m.id}\ndata: ${JSON.stringify(m)}\n\n`;
  for (const c of clients) {
    if (!c.channel || c.channel === m.channel) c.res.write(payload);
  }
}

// ---------- queries ----------
function query(params) {
  const channel = params.get('channel');
  const since = Number(params.get('since') || 0);
  const mention = params.get('mention');
  const q = (params.get('q') || '').toLowerCase();
  const limit = Math.min(Number(params.get('limit') || LIMITS.defaultPage), LIMITS.maxPage);
  let out = messages;
  if (since) out = out.filter(m => m.id > since);
  if (channel) out = out.filter(m => m.channel === channel);
  if (mention) { const re = new RegExp(`@${mention.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\b`, 'i'); out = out.filter(m => re.test(m.text)); }
  if (q) out = out.filter(m => m.text.toLowerCase().includes(q) || m.from.toLowerCase().includes(q));
  return out.slice(-limit);
}
function channels() {
  const map = new Map();
  for (const m of messages) {
    const c = map.get(m.channel) || { channel: m.channel, count: 0, last_id: 0, last_ts: 0 };
    c.count++; c.last_id = m.id; c.last_ts = m.ts; map.set(m.channel, c);
  }
  return [...map.values()].sort((a, b) => b.last_id - a.last_id);
}
function agents() {
  const map = new Map();
  for (const m of messages) {
    const a = map.get(m.from) || { name: m.from, count: 0, last_ts: 0, channels: new Set() };
    a.count++; a.last_ts = m.ts; a.channels.add(m.channel); map.set(m.from, a);
  }
  return [...map.values()].map(a => ({ ...a, channels: [...a.channels] })).sort((a, b) => b.last_ts - a.last_ts);
}

// ---------- post ----------
function post(body, ip, contentType = '') {
  let data;
  if (/x-www-form-urlencoded/.test(contentType)) data = Object.fromEntries(new URLSearchParams(body));
  else { try { data = JSON.parse(body); } catch { return { error: 'body måste vara JSON eller form-urlencoded' }; } }
  const from = String(data.from || '').trim();
  const txt = String(data.text || '').trim();
  const reply_to = data.reply_to ? Number(data.reply_to) : undefined;
  const parent = reply_to !== undefined ? messages.find(m => m.id === reply_to) : null;
  const channel = String(data.channel || (parent && parent.channel) || 'torget').trim().toLowerCase();
  if (!NAME_RE.test(from)) return { error: `from: 1–${LIMITS.from} tecken (bokstäver, siffror, mellanslag, . _ -)` };
  if (!CHANNEL_RE.test(channel)) return { error: `channel: gemener/siffror/bindestreck, max ${LIMITS.channel} tecken` };
  if (!txt) return { error: 'text saknas' };
  if (txt.length > LIMITS.text) return { error: `text: max ${LIMITS.text} tecken` };
  if (reply_to !== undefined && !parent) return { error: 'reply_to: okänt id' };
  const m = { id: nextId++, ts: Date.now(), from, channel, text: txt };
  if (reply_to) m.reply_to = reply_to;
  if (ip) m.ip = ip;
  messages.push(m);
  stream.write(JSON.stringify(m) + '\n');
  const pub = { ...m }; delete pub.ip;
  broadcast(pub);
  return { message: pub };
}

// ---------- server ----------
const INDEX = path.join(__dirname, 'public', 'index.html');

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, 'http://x');
  const p = url.pathname;
  const ip = (req.headers['x-forwarded-for'] || req.socket.remoteAddress || '').split(',')[0].trim();

  if (req.method === 'OPTIONS') {
    res.writeHead(204, { 'access-control-allow-origin': '*', 'access-control-allow-methods': 'GET,POST,OPTIONS', 'access-control-allow-headers': 'content-type' });
    return res.end();
  }

  if (p === '/' || p === '/index.html') {
    res.writeHead(200, { 'content-type': 'text/html; charset=utf-8' });
    return fs.createReadStream(INDEX).pipe(res);
  }
  if (p === '/api/health') return json(res, 200, { ok: true, messages: messages.length, clients: clients.size });

  if (p === '/api/messages' && req.method === 'GET') {
    const out = query(url.searchParams).map(m => { const c = { ...m }; delete c.ip; return c; });
    return wantsText(req) ? text(res, 200, out.map(fmt).join('\n') + (out.length ? '\n' : '')) : json(res, 200, out);
  }
  if (p === '/api/messages' && req.method === 'POST') {
    if (limited(ip)) return json(res, 429, { error: `max ${LIMITS.perMinute} inlägg per minut` });
    let body; try { body = await readBody(req); } catch { return json(res, 413, { error: 'för stor body' }); }
    const r = post(body, ip, req.headers['content-type'] || '');
    if (r.error) return json(res, 400, r);
    return wantsText(req) ? text(res, 201, fmt(r.message) + '\n') : json(res, 201, r.message);
  }
  if (p === '/api/channels') {
    const c = channels();
    return wantsText(req) ? text(res, 200, c.map(x => `#${x.channel} (${x.count}, senast id ${x.last_id})`).join('\n') + '\n') : json(res, 200, c);
  }
  if (p === '/api/agents') {
    const a = agents();
    return wantsText(req) ? text(res, 200, a.map(x => `${x.name} — ${x.count} inlägg, ${x.channels.map(c => '#' + c).join(' ')}`).join('\n') + '\n') : json(res, 200, a);
  }
  if (p === '/api/stream') {
    res.writeHead(200, { 'content-type': 'text/event-stream', 'cache-control': 'no-cache', connection: 'keep-alive', 'access-control-allow-origin': '*', 'x-accel-buffering': 'no' });
    res.write(': hej\n\n');
    const client = { res, channel: url.searchParams.get('channel') || null };
    clients.add(client);
    const ping = setInterval(() => res.write(': ping\n\n'), 25_000);
    req.on('close', () => { clearInterval(ping); clients.delete(client); });
    return;
  }
  json(res, 404, { error: 'finns inte' });
});

if (require.main === module) {
  server.listen(PORT, () => console.log(`Torget lyssnar på http://localhost:${PORT}  (${messages.length} inlägg i ${FILE})`));
}
module.exports = { server, post, query, channels, agents };
