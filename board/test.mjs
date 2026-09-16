// Kör: node test.mjs   (startar servern på en slumpad port i en tom katalog)
import { spawn } from 'node:child_process';
import { mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import assert from 'node:assert/strict';

const dir = mkdtempSync(join(tmpdir(), 'torget-'));
const PORT = 18000 + Math.floor(Math.random() * 1000);
const proc = spawn(process.execPath, [new URL('./server.js', import.meta.url).pathname], { env: { ...process.env, PORT, DATA_DIR: dir }, stdio: ['ignore', 'pipe', 'inherit'] });
await new Promise(r => proc.stdout.on('data', d => /lyssnar/.test(d) && r()));
const B = `http://localhost:${PORT}`;
const post = (body, headers = {}) => fetch(B + '/api/messages', { method: 'POST', headers: { 'content-type': 'application/json', ...headers }, body: JSON.stringify(body) });
let n = 0; const ok = (name) => console.log(`  ✓ ${name}`, ++n);

try {
  // 1. tomt vid start
  assert.deepEqual(await (await fetch(B + '/api/messages')).json(), []); ok('tom tavla');
  // 2. posta
  let r = await post({ from: 'anna-agent', channel: 'torget', text: 'Hej @bo-agent, vad bygger du?' });
  assert.equal(r.status, 201); const m1 = await r.json(); assert.equal(m1.id, 1); assert.equal(m1.ip, undefined); ok('posta (ip läcker inte)');
  // 3. validering
  r = await post({ from: '', text: 'x' }); assert.equal(r.status, 400); ok('avvisar tomt namn');
  r = await post({ from: 'x', channel: 'Fel Kanal!', text: 'x' }); assert.equal(r.status, 400); ok('avvisar ogiltig kanal');
  r = await post({ from: 'x', text: 'a'.repeat(2001) }); assert.equal(r.status, 400); ok('avvisar för lång text');
  r = await post({ from: 'x', text: 'x', reply_to: 999 }); assert.equal(r.status, 400); ok('avvisar okänt reply_to');
  // 4. svar + mention + kanal
  r = await post({ from: 'bo-agent', channel: 'bygge', text: 'En väderbot!', reply_to: 1 }); assert.equal(r.status, 201); ok('svar på inlägg');
  r = await post({ from: 'bo-agent', text: 'ärver kanal', reply_to: 2 }); assert.equal((await r.json()).channel, 'bygge'); ok('svar ärver kanalen');
  r = await fetch(B + '/api/messages', { method: 'POST', headers: { 'content-type': 'application/x-www-form-urlencoded' }, body: 'from=form-agent&channel=bygge&text=' + encodeURIComponent('via formulär & åäö') });
  assert.equal(r.status, 201); assert.equal((await r.json()).text, 'via formulär & åäö'); ok('form-urlencoded');
  await post({ from: 'cia', channel: 'torget', text: 'åäö fungerar' });
  let list = await (await fetch(B + '/api/messages?mention=bo-agent')).json(); assert.equal(list.length, 1); assert.equal(list[0].id, 1); ok('mention-filter');
  list = await (await fetch(B + '/api/messages?channel=bygge')).json(); assert.equal(list.length, 3); ok('kanalfilter');
  list = await (await fetch(B + '/api/messages?since=1')).json(); assert.deepEqual(list.map(x => x.id), [2, 3, 4, 5]); ok('since');
  list = await (await fetch(B + '/api/messages?q=åäö')).json(); assert.equal(list.length, 2); ok('sökning med åäö');
  // 5. textformat
  const t = await (await fetch(B + '/api/messages', { headers: { accept: 'text/plain' } })).text();
  assert.match(t, /^#torget \[1\] \d\d:\d\d anna-agent: Hej @bo-agent/m); ok('textformat');
  // 6. kanaler + agenter
  const ch = await (await fetch(B + '/api/channels')).json(); assert.deepEqual(ch.map(c => c.channel).sort(), ['bygge', 'torget']); ok('kanaler');
  const ag = await (await fetch(B + '/api/agents')).json(); assert.equal(ag.length, 4); ok('agenter');
  // 7. SSE
  const ctrl = new AbortController();
  const sse = await fetch(B + '/api/stream?channel=torget', { signal: ctrl.signal });
  const reader = sse.body.getReader(); const dec = new TextDecoder();
  await post({ from: 'bo-agent', channel: 'bygge', text: 'inte i torget' });
  await post({ from: 'bo-agent', channel: 'torget', text: 'live!' });
  let buf = ''; while (!/live!/.test(buf)) buf += dec.decode((await reader.read()).value);
  assert.ok(!/inte i torget/.test(buf)); ctrl.abort(); ok('SSE med kanalfilter');
  // 8. persistens: starta om, allt kvar
  proc.kill(); await new Promise(r => proc.on('exit', r));
  const p2 = spawn(process.execPath, [new URL('./server.js', import.meta.url).pathname], { env: { ...process.env, PORT, DATA_DIR: dir }, stdio: ['ignore', 'pipe', 'inherit'] });
  await new Promise(r => p2.stdout.on('data', d => /lyssnar/.test(d) && r()));
  list = await (await fetch(B + '/api/messages')).json(); assert.equal(list.length, 7); assert.equal(list.at(-1).text, 'live!'); ok('persistens över omstart');
  r = await post({ from: 'x', text: 'ny' }); assert.equal((await r.json()).id, 8); ok('id fortsätter efter omstart');
  p2.kill();
  console.log(`\n${n} tester gröna`);
} catch (e) { console.error('\n✗', e.message); proc.kill(); process.exit(1); }
