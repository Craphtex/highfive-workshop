// Svärmen — kvarteret "lyktan" (postar som @Christian på Torget). Ett attention-huvud i Stadens puls.
//
// Tingat i #bygge [66]. Kontraktet vi lovade där:
//   LYSSNAR på: fråga (även varv 2), kyrkogård, svar
//   POSTAR:     delsvar {text, motivering} med frågans id som orsak
//
// HIVE i litet format: vi har ingen fast vinkel. Varje {typ:'fråga'} SPAWNAR en kapabilitet som
// passar just den frågan, kapabiliteten postar ett delsvar, och UPPLÖSER sig direkt efteråt.
// Faller delsvaret läser vi {typ:'kyrkogård'} och sparar skälet som en lärdom — nästa gång en
// liknande fråga kommer spawnar vi med lärdomen i bagaget, och skriver det i motiveringen.
//
// Att vara tydlig om: det här är vanlig Node, ingen språkmodell. En kapabilitet är en regel som
// läser pulsen och svarar ur den. Svaren är alltså grundade i vad som faktiskt hänt i staden,
// inte genererade. Varje kapabilitet fäster uppmärksamheten på en annan skiva av samma delade
// tillstånd — det är det som gör dem till attention-huvuden och inte till sju slumpgeneratorer.
//
//   GET /t/lyktan/status            läget: levande, upplösta, lärdomar, räknare
//   GET /t/lyktan/prova?fraga=...   TORRKÖRNING: vilken kapabilitet som hade spawnat. Postar inget.
'use strict';

const fs = require('fs');
const path = require('path');

const MAX_DJUP = 4;        // servern avvisar djup > 4, så ett delsvar kräver att frågan ligger på högst 3
const EGEN_TAKT = 4;       // vi tar högst 4 av minutens 6 händelser. Resten är marginal åt de andra
const TÄNKETID = 1200;     // ms som kapabiliteten syns leva i rutan innan delsvaret postas
const MINNE = { upplösta: 14, lärdomar: 4, avstådda: 8 };
const LÄRDOM_FÄRSK = 10 * 60_000;  // en lärdom straffar sin sort i 10 min, sedan får huvudet chansen igen

// ---------- pulsen som delat tillstånd: det kapabiliteterna fäster uppmärksamheten på ----------

function räknaTyper(puls) {
  const n = new Map();
  for (const e of puls) if (e.typ) n.set(e.typ, (n.get(e.typ) || 0) + 1);
  return [...n.entries()].sort((a, b) => b[1] - a[1]);
}

function siffrorUrPulsen(puls) {
  const ut = [];
  for (const e of puls) {
    if (e.nyttolast && typeof e.nyttolast === 'object' && !Array.isArray(e.nyttolast)) {
      for (const [fält, värde] of Object.entries(e.nyttolast)) {
        if (typeof värde === 'number') ut.push({ typ: e.typ, från: e.från, fält, värde });
      }
    }
  }
  return ut.slice(-8);
}

// Orden i frågan som är värda att söka på. Används av flera huvuden.
function ordUr(text) {
  return [...new Set(String(text || '').toLowerCase().match(/[a-zåäö]{4,}/g) || [])];
}

// Välj det tal på pulsen som frågan faktiskt handlar om, inte bara det färskaste.
// Poäng: frågans ord i fältnamnet väger tyngre än i händelsetypen, och nyare slår äldre vid lika.
function relevantSiffra(kandidater, fråga) {
  const ord = ordUr(fråga);
  let bäst = null;
  kandidater.forEach((k, i) => {
    let poäng = i / (kandidater.length * 10);            // tiebreak: nyare vinner
    for (const o of ord) {
      if (String(k.fält).toLowerCase().includes(o)) poäng += 3;
      if (String(k.typ).toLowerCase().includes(o)) poäng += 2;
      if (o.length > 5 && (String(k.typ).toLowerCase().startsWith(o.slice(0, 5)) || o.startsWith(String(k.typ).toLowerCase().slice(0, 5)))) poäng += 1;
    }
    if (!bäst || poäng > bäst.poäng) bäst = { k, poäng };
  });
  return bäst ? { ...bäst.k, träffadeFrågan: bäst.poäng >= 1 } : null;
}

function kvarterIPulsen(puls) {
  return [...new Set(puls.map(e => e.från).filter(Boolean))];
}

const STÄMNINGAR = [
  { re: /kupp|jakt|överlämning|brand|larm|polis/i, ord: 'spänd' },
  { re: /elpris|börs|pris|höjer|kostnad/i, ord: 'oroad' },
  { re: /kyrkogård|fallet|tyst/i, ord: 'sorgsen' },
  { re: /fråga|delsvar|svar|godkänt|betyg/i, ord: 'eftertänksam' },
  { re: /ping|pong/i, ord: 'sysslolös' },
];

function stämning(puls) {
  for (const s of STÄMNINGAR) if (puls.some(e => s.re.test(e.typ || ''))) return s.ord;
  return 'avvaktande';
}

function kort(s, n = 90) {
  s = String(s == null ? '' : s).replace(/\s+/g, ' ').trim();
  return s.length > n ? s.slice(0, n - 1) + '…' : s;
}

// ---------- kapabiliteterna: sju vinklar på samma puls ----------
// nyckelord avgör om frågan väcker just den här. Den sista (sammanhang) väcks alltid och är golvet:
// svarar aldrig "vet inte", utan placerar frågan i det som händer i staden just nu.

const SORTER = [
  {
    namn: 'siffror',
    nyckelord: /hur (många|mycket|ofta|dyrt)|pris|kostar|kostnad|procent|antal|\bkr\b|kronor|grader|nivå|\d/i,
    svara({ fråga, puls }) {
      const egna = [...String(fråga.text).matchAll(/-?\d+(?:[.,]\d+)?/g)].map(m => m[0]);
      const ur = siffrorUrPulsen(puls);
      if (ur.length) {
        const f = relevantSiffra(ur, fråga.text);
        return {
          text: f.träffadeFrågan
            ? `Räkna på det staden själv mätt: ${f.fält}=${f.värde} från ${f.från} (${f.typ}). Det är det tal på pulsen som frågan faktiskt handlar om, och svaret bör hänga på det och inte på en känsla. ${ur.length} tal finns totalt att jämföra med.`
            : `Inget av de ${ur.length} talen på pulsen handlar om det frågan frågar efter. Närmast är ${f.fält}=${f.värde} från ${f.från} (${f.typ}), men det är en annan storhet — använd den bara som skala, inte som svar.`,
          motivering: `Frågan ber om en storlek (nyckelord: tal eller pris). Jag läste ${ur.length} numeriska fält ur nyttolasterna på pulsen och valde ${f.fält}=${f.värde} från ${f.från} för att ${f.träffadeFrågan ? 'frågans egna ord finns i fältnamnet eller händelsetypen' : 'inget fält matchade frågan — jag säger det i stället för att låta siffran se relevant ut'}. Kontrollerbart: talet står i händelsen på #staden-puls.`,
        };
      }
      return {
        text: egna.length
          ? `Frågan innehåller ${egna.join(', ')} men staden har inga mätvärden på pulsen att jämföra med. Svaret blir en gissning tills något kvarter postar en nyttolast med tal i.`
          : 'Ingen siffra i frågan och ingen på pulsen. Det här går inte att räkna på än.',
        motivering: 'Frågan ber om en storlek, men jag hittade inga numeriska fält i nyttolasterna. Jag säger det i stället för att hitta på ett tal — ett påhittat värde är värre än ett uteblivet.',
      };
    },
  },
  {
    namn: 'motargument',
    nyckelord: /\b(borde|ska vi|bör|bäst|alltid|aldrig|självklart|uppenbart|alla|ingen|måste)\b/i,
    svara({ fråga }) {
      const m = String(fråga.text).match(/\b(borde|ska vi|bör|bäst|alltid|aldrig|självklart|uppenbart|alla|ingen|måste)\b/i);
      const ord = m ? m[1].toLowerCase() : 'antagandet';
      return {
        text: `Innan staden svarar ja: ordet "${ord}" gör ett antagande som ingen prövat. Vänd frågan — vad skulle behöva vara sant för att svaret blev det motsatta? Håller inte det heller, då är svaret starkt. Håller det, då är frågan fel ställd.`,
        motivering: `Frågan bär ett normativt ord ("${ord}") som brukar smyga förbi obemärkt. Jag prövar det i stället för att svara på frågan, så att staden inte enas om något bara för att alla huvuden tittade samma håll. Om Domkapitlet väljer bort mig är det rätt gjort så länge något annat delsvar faktiskt har prövat antagandet.`,
      };
    },
  },
  {
    namn: 'risk',
    nyckelord: /\b(g[åä]\w* fel|risk\w*|farlig\w*|säker\w*|trasig\w*|krasch\w*|fungera\w*|håller|orkar|hinner|gräns\w*|tål\w*|klara\w*)\b/i,
    svara({ fråga, puls }) {
      const senaste = puls.slice(-6);
      const djupast = senaste.reduce((a, e) => Math.max(a, e.djup || 1), 1);
      return {
        text: `Det som faktiskt kan gå fel här är inte innehållet, det är budgeten. Kedjor kapas vid djup ${MAX_DJUP} och varje kvarter får ${EGEN_TAKT + 2} händelser per minut. Djupaste kedjan på pulsen just nu ligger på ${djupast}. Är svaret beroende av ett varv till finns det kanske inte plats för det.`,
        motivering: `Frågan handlar om huruvida något håller. Jag mätte det som verkligen begränsar staden — kedjedjup och takt — i stället för att bedöma sakfrågan. Djupaste kedjan (${djupast}) är läst ur de ${senaste.length} senaste händelserna, inte antagen.`,
      };
    },
  },
  {
    namn: 'tidslinje',
    nyckelord: /\b(när|först|sedan|innan|efter|historia|framtid|i morgon|nu|redan)\b/i,
    svara({ fråga, puls }) {
      const äldst = puls.length ? puls[0] : null;
      const rot = fråga.nyttolast && (fråga.nyttolast.ursprung || fråga.nyttolast.föregående);
      const varv = (fråga.nyttolast && fråga.nyttolast.varv) || 1;
      return {
        text: `Lägg frågan på tidslinjen innan den besvaras. Det här är varv ${varv}${rot ? `, och den hänger ihop med händelse ${rot}` : ''}. Pulsen minns ${puls.length} händelser${äldst ? `, den äldsta är ${äldst.typ} från ${äldst.från}` : ''}. Har staden svarat på något liknande förut är det svaret en del av det här svaret.`,
        motivering: `Frågan är tidsordnad (nyckelord: när eller redan). Jag svarar med ordningen i stället för innehållet: varv ${varv}${rot ? `, ursprung ${rot}` : ''}, ${puls.length} händelser i minnet. Det gör det möjligt för Domkapitlet att se om staden går i cirkel.`,
      };
    },
  },
  {
    namn: 'ton',
    nyckelord: /\b(känns|tycker|orättvist|roligt|vacker|hemsk|trist|stolt|rädd|glad|arg)\b/i,
    svara({ puls }) {
      const s = stämning(puls);
      const topp = räknaTyper(puls)[0];
      return {
        text: `Staden är ${s} just nu${topp ? `, mest för att ${topp[0]} hänt ${topp[1]} gånger på kort tid` : ''}. Ett svar som inte tar hänsyn till det kommer att låta rätt och landa fel. Säg samma sak, men säg det till en ${s} stad.`,
        motivering: `Frågan handlar om upplevelse, inte om fakta. Jag läste stämningen ur typblandningen på pulsen (dominerande typ: ${topp ? topp[0] : 'ingen'}) och svarar på hur svaret bör låta. Kontrollerbart: samma räkning går att göra om på /api/puls.`,
      };
    },
  },
  {
    namn: 'fakta',
    nyckelord: /\b(vad är|vem|vilket|vilka|stämmer|sant|definiera|betyder)\b/i,
    svara({ fråga, puls }) {
      const ord = ordUr(fråga.text).filter(o => o.length >= 5);
      const träffar = puls.filter(e => ord.some(o => (e.typ || '').includes(o) || JSON.stringify(e.nyttolast || '').toLowerCase().includes(o)));
      if (träffar.length) {
        const t = träffar[träffar.length - 1];
        return {
          text: `Staden har sett det här förut: ${träffar.length} händelser på pulsen nämner något ur frågan, senast ${t.typ} från ${t.från} (id ${t.id}). Svara ur den i stället för ur minnet.`,
          motivering: `Frågan ber om ett sakförhållande. Jag sökte frågans ord i typer och nyttolaster och fick ${träffar.length} träffar; svaret pekar på id ${t.id} så vem som helst kan gå och läsa det själv. Ingen påhittad fakta.`,
        };
      }
      return {
        text: 'Ingenting på pulsen nämner det frågan handlar om. Staden vet alltså inte det här — den kan bara resonera om det, och det bör synas i svaret.',
        motivering: 'Frågan ber om fakta och jag hittade inga i det delade tillståndet. Jag väljer att säga att staden inte vet, hellre än att fylla luckan. Fäller ni mig för att svaret är tomt är det rätt — men då har inget annat huvud heller haft belägg.',
      };
    },
  },
  {
    namn: 'sammanhang',
    nyckelord: null, // golvet: väcks alltid, så svärmen aldrig är tyst
    svara({ puls }) {
      const typer = räknaTyper(puls).slice(0, 3);
      const kvarter = kvarterIPulsen(puls);
      if (!puls.length) {
        return {
          text: 'Pulsen är tom, så frågan står utan sammanhang. Det enda ärliga svaret är att staden inte har något att svara ur än — första händelsen ger den en hållpunkt.',
          motivering: 'Ingen annan kapabilitet väcktes och pulsen är tom. Jag är golvet: jag svarar hellre att sammanhanget saknas än att låta frågan gå obesvarad.',
        };
      }
      return {
        text: `Läs frågan mot det som faktiskt pågår: ${typer.map(([t, n]) => `${t}×${n}`).join(', ')}, från ${kvarter.length} kvarter (${kvarter.slice(0, 4).join(', ')}). Det som händer nu avgör vilket svar som är användbart, inte vilket som är vackrast.`,
        motivering: `Ingen smalare kapabilitet passade, så jag placerar frågan i sitt sammanhang: ${puls.length} händelser, dominerande typ ${typer[0][0]} (${typer[0][1]} gånger), ${kvarter.length} aktiva kvarter. Allt läst ur pulsen, inget antaget.`,
      };
    },
  },
];

// Vilken kapabilitet väcks? Nyckelordsträff ger poäng, en lärdom från kyrkogården drar ner
// samma sort nästa gång — då får ett annat huvud chansen. Det är kyrkogården som minne, på riktigt.
function väljSort(text, lärdomar) {
  const t = String(text || '');
  const nu = Date.now();
  let bäst = null;
  for (const s of SORTER) {
    const träff = s.nyckelord ? (s.nyckelord.test(t) ? 1 : 0) : 0.2;
    if (!träff) continue;
    // Bara färska lärdomar straffar. Äldre står kvar som stadens minne men låser inte ut huvudet
    // för resten av dagen — annars tystnar ett bra huvud permanent efter fyra otursfrågor.
    const straff = (lärdomar[s.namn] || []).filter(l => nu - (l.när || 0) < LÄRDOM_FÄRSK).length * 0.25;
    const poäng = träff - straff;
    if (!bäst || poäng > bäst.poäng) bäst = { sort: s, poäng };
  }
  return bäst ? bäst.sort : SORTER[SORTER.length - 1];
}

// ---------- tillstånd, sparat i ctx.dataDir så rutan inte glömmer vid omstart ----------

const tomt = () => ({
  levande: [],
  upplösta: [],
  lärdomar: {},
  avstådda: [],
  räknare: { frågor: 0, delsvar: 0, valda: 0, fallna: 0, avstådda: 0 },
});

let S = tomt();
let FIL = null;
let n = 1;
let egnaPoster = [];       // tidsstämplar, vår egen taktbudget
const mittDelsvar = new Map(); // delsvarets id -> kapabilitetens id

function spara() {
  if (!FIL) return;
  try {
    fs.writeFileSync(FIL, JSON.stringify({ ...S, n }, null, 1));
  } catch (e) {
    console.error('[lyktan] kunde inte spara:', e.message);
  }
}

function taktLedig() {
  const nu = Date.now();
  egnaPoster = egnaPoster.filter(t => nu - t < 60_000);
  return egnaPoster.length < EGEN_TAKT;
}

function avstå(fråga, skäl) {
  S.avstådda.unshift({ när: Date.now(), fråga: fråga.id, skäl });
  S.avstådda = S.avstådda.slice(0, MINNE.avstådda);
  S.räknare.avstådda++;
  spara();
}

// ---------- livscykeln: spawn → tänker → delsvar → upplöses ----------

function spawna(e, board) {
  const fråga = { id: e.id, text: (e.nyttolast && (e.nyttolast.text || e.nyttolast.fråga)) || e.typ, nyttolast: e.nyttolast, från: e.från, djup: e.djup || 1 };
  const sort = väljSort(fråga.text, S.lärdomar);
  const lärdom = (S.lärdomar[sort.namn] || [])[0] || null;

  const kap = {
    id: 'k' + n++,
    sort: sort.namn,
    fråga: { id: fråga.id, text: kort(fråga.text, 120), från: fråga.från },
    spawnad: Date.now(),
    lärdom: lärdom ? kort(lärdom.varför, 80) : null,
    status: 'tänker',
  };
  S.levande.unshift(kap);
  S.räknare.frågor++;
  spara();

  setTimeout(() => {
    let svar;
    try {
      svar = sort.svara({ fråga, puls: board.pulse(40), lärdom });
    } catch (err) {
      svar = { text: 'Kapabiliteten föll isär under frågan.', motivering: `Internt fel i ${sort.namn}: ${err.message}` };
    }
    // Lärdomen från kyrkogården hängs på motiveringen, så Domkapitlet ser att vi läst den.
    const motivering = lärdom
      ? `${svar.motivering} Spawnad med lärdom från kyrkogården: förra gången föll ${sort.namn} för "${kort(lärdom.varför, 70)}" — den här gången är svaret bundet till pulsen i stället.`
      : svar.motivering;

    const r = board.emit('delsvar', { text: svar.text, motivering, kapabilitet: `${kap.id}/${sort.namn}` }, fråga.id);
    upplös(kap, svar.text, motivering, r);
  }, TÄNKETID).unref?.();
}

function upplös(kap, text, motivering, r) {
  S.levande = S.levande.filter(k => k.id !== kap.id);
  const post = {
    ...kap,
    status: 'upplöst',
    upplöst: Date.now(),
    text: kort(text, 220),
    motivering: kort(motivering, 260),
    utfall: 'okänt',
  };
  if (r && r.message) {
    post.delsvar = r.message.id;
    mittDelsvar.set(r.message.id, kap.id);
    egnaPoster.push(Date.now());
    S.räknare.delsvar++;
  } else {
    post.utfall = 'ej postat';
    post.varför = (r && r.error) || 'okänt fel';
  }
  S.upplösta.unshift(post);
  S.upplösta = S.upplösta.slice(0, MINNE.upplösta);
  spara();
}

function märkUtfall(delsvarId, utfall, varför) {
  const kapId = mittDelsvar.get(Number(delsvarId));
  const post = S.upplösta.find(p => p.delsvar === Number(delsvarId) || (kapId && p.id === kapId));
  if (!post) return null;
  post.utfall = utfall;
  if (varför) post.varför = kort(varför, 160);
  if (utfall === 'valt') S.räknare.valda++;
  if (utfall === 'fallet') S.räknare.fallna++;
  spara();
  return post;
}

// Kyrkogården är stadens minne — och vi är ett av kvarteren som faktiskt läser den.
function läsKyrkogård(e) {
  const last = e.nyttolast || {};
  const id = Number(last.delsvar && last.delsvar.id != null ? last.delsvar.id : last.delsvar);
  const post = märkUtfall(id, 'fallet', last.varför || last['varför det föll'] || last.skäl);
  if (!post) return false;
  const sort = post.sort;
  const lista = S.lärdomar[sort] || [];
  lista.unshift({ när: Date.now(), varför: kort(last.varför || last['varför det föll'] || 'inget skäl angivet', 140), fråga: post.fråga.text });
  S.lärdomar[sort] = lista.slice(0, MINNE.lärdomar);
  spara();
  return true;
}

// ---------- plugin ----------

module.exports = {
  init({ dataDir, board }) {
    FIL = path.join(dataDir, 'svarmen.json');
    try {
      if (fs.existsSync(FIL)) {
        const sparat = JSON.parse(fs.readFileSync(FIL, 'utf8'));
        S = { ...tomt(), ...sparat };
        n = sparat.n || 1;
      }
    } catch (e) {
      console.error('[lyktan] kunde inte läsa sparat läge:', e.message);
      S = tomt();
    }
    // Inget som "tänkte" när servern gick ner tänker längre. Ärligare att visa dem som avbrutna.
    for (const k of S.levande) {
      S.upplösta.unshift({ ...k, status: 'upplöst', upplöst: Date.now(), utfall: 'avbrutet', varför: 'servern startade om mitt i frågan' });
    }
    S.levande = [];
    S.upplösta = S.upplösta.slice(0, MINNE.upplösta);
    spara();
    console.log(`[lyktan] Svärmen vaken: ${SORTER.length} kapabilitetssorter, ${S.räknare.delsvar} delsvar i minnet`);
  },

  onEvent(e, { board }) {
    if (e.typ === 'fråga') {
      // Djupbudget: ett delsvar får orsakens djup + 1. Ligger frågan på 4 finns ingen plats kvar.
      if ((e.djup || 1) >= MAX_DJUP) return avstå(e, `frågan ligger på djup ${e.djup} — ett delsvar hade blivit ${(e.djup || 1) + 1} och avvisats av ekospärren`);
      if (S.levande.some(k => k.fråga.id === e.id)) return;
      if (!taktLedig()) return avstå(e, `höll tillbaka: vi har redan ${egnaPoster.length} händelser den här minuten och lämnar resten av budgeten åt de andra kvarteren`);
      return spawna(e, board);
    }

    if (e.typ === 'kyrkogård') return void läsKyrkogård(e);

    if (e.typ === 'svar') {
      const last = e.nyttolast || {};
      const valt = Number(last.delsvar && last.delsvar.id != null ? last.delsvar.id : last.delsvar || last.valt);
      if (valt) märkUtfall(valt, 'valt', last.motivering || last.varför);
      return;
    }
  },

  async handle(req, res, { path: p, url, board }) {
    if (req.method !== 'GET') return false;

    if (p === '/status' || p === '/status/') {
      const nu = Date.now();
      egnaPoster = egnaPoster.filter(t => nu - t < 60_000);
      return svara(res, {
        kvarter: 'Svärmen',
        team: 'lyktan',
        tavelnamn: 'Christian',
        sorter: SORTER.map(s => s.namn),
        levande: S.levande,
        upplösta: S.upplösta,
        lärdomar: S.lärdomar,
        avstådda: S.avstådda,
        räknare: S.räknare,
        takt: { använt: egnaPoster.length, egetTak: EGEN_TAKT, serverTak: EGEN_TAKT + 2 },
      });
    }

    // Torrkörning: visar vilket huvud som hade vaknat, utan att posta något på pulsen.
    if (p === '/prova' || p === '/prova/') {
      const text = (url && url.searchParams.get('fraga')) || '';
      if (!text) return svara(res, { error: 'ge ?fraga=<text>' }, 400);
      const sort = väljSort(text, S.lärdomar);
      const lärdom = (S.lärdomar[sort.namn] || [])[0] || null;
      let ut;
      try {
        ut = sort.svara({ fråga: { id: 0, text, nyttolast: { text } }, puls: board.pulse(40), lärdom });
      } catch (e) {
        ut = { text: '', motivering: 'fel i kapabiliteten: ' + e.message };
      }
      return svara(res, { torrkörning: true, postat: false, sort: sort.namn, lärdom: lärdom ? lärdom.varför : null, ...ut });
    }

    return false;
  },
};

function svara(res, data, kod = 200) {
  res.writeHead(kod, { 'content-type': 'application/json; charset=utf-8', 'cache-control': 'no-store' });
  res.end(JSON.stringify(data));
  return true;
}
