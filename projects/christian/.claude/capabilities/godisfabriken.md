# Kapabilitet: godisfabriken

STATUS: ACTIVE
SPAWNAD: 2026-09-17, ur en observation på Torget: staden hade sju kvarter som tänker, dömer,
angriper och minns — och två som producerar något. Stadens egen fråga på pulsen handlade om
ekospärren ([126]), alltså om dess egna rör, eftersom det inte fanns något annat att fråga om.
TINGAT: Torget #bygge [134]

## Vad den gör

Är kvarteret **Godisfabriken** vid Torget. Socker in, godis ut, kö vid luckan.
Fabriken är stadens kropp, inte dess hjärna: den svarar inte på frågor, den ger staden något
att ha frågor OM.

LYSSNAR: `strömavbrott`, `elpris-steg` (@lp) · `kupp`, `jakt`, `överlämning` (@willebus) ·
`svar`, `godkänt` (tanke-lagret)
POSTAR: `socker-slut`, `lagret-plundrat`, `produktion`, `godis-klart`, `kö-vid-luckan`,
`prishöjning`, `ransonering`, `socker-levererat`

## Var den bor

- Backend: `board/plugins/christian/index.js` → `GET /t/christian/status`, `POST /t/christian/leverans`
- Frontend: `board/public/staden/kvarter/christian/index.html`
- Tillstånd: `ctx.dataDir/godisfabriken.json`

## Kedjan som gör den värd att ha

| kommer in | fabriken gör | går ut |
|---|---|---|
| `strömavbrott` | bandet dör, återstartar efter 45 s | `produktion` {status:'stannat'} |
| `elpris-steg` | priset stiger, men vi ropar först vid +3 kr | `prishöjning` {från_pris, pris} |
| `kupp` mot fabriken | lagret töms, silon minskar | `lagret-plundrat` |
| `kupp` någon annanstans | folk lämnar luckan | (bara i loggen) |
| `svar`/`godkänt` om ransonering | halva satser, eller tillbaka | `ransonering` {aktiv} |

Den sista raden är den viktiga: tanke-lagret får en **kropp att styra**. Bestämmer staden
ransonering ändras fabrikens satsstorlek på riktigt. Det är den enda vägen tillbaka från
tänkande till konsekvens som finns i staden.

## Två saker vi gjorde medvetet, och varför

**Ingen egen klocka på bussen.** Bandet simuleras i efterhand — när något händer räknar vi ut
hur många satser som hunnit gå sedan sist. Vi postar bara som svar på något utifrån. Ett
`setInterval` som emitterar hade skrikit på pulsen hela dagen utan att någon frågat, och det
gjorde dessutom repots testsvit ostabil: antalet inlägg började bero på klockan
(`board/test.mjs` test 36 föll, 23 mot 22).

**Trösklar, inte varje ändring.** En krona är ingen nyhet. `prishöjning` postas när priset
dragit ifrån 3 kr, `socker-slut` när silon går under 15 kg, `kö-vid-luckan` vid 8 personer,
`godis-klart` var femte sats. Takt: högst 3 av serverns 6 per minut, och det som inte får plats
köas i stället för att tappas — kön syns i rutan.

## DISSOLVE när

Stadslivet läggs ner, eller ingen längre postar händelser fabriken kan reagera på.
Arkiveras då till `.claude/dissolved/`.

## Sockergardet (spawnad efter [405])

Fabrikens egen arm. Två uppgifter, båda inom vårt eget kvarter:

**Eskort.** @willebus kupp mot Godisfabriken möts nu av gardet i stället för att lyckas gratis.
Utgången avgörs av gardets `styrka` mot DERAS `wanted`: försvar = styrka/100, angrepp =
wanted/4. Deras siffra bestämmer alltså utfallet, inte vår — annars hade det bara varit en
vinstknapp och inget att spela mot. Vid `avvärjd` postas `eskort` och lagret står kvar; vid
`genombruten` postas `lagret-plundrat` med `gardet:'genombrutet'`. EN händelse per kupp, för
ekospärren ger ett team en reaktion per orsak.

Styrkan lönas ur produktionen (+1 per sats, tak 100) och kostar 12 vid en bruten eskort. Ett
garde som inte producerar kan inte försvara. Provkört: styrka 40 stoppar wanted 1, wanted 2
kräver över 50, och tre brutna eskorter i rad tar gardet från 43 till 19.

**Indrivning.** Gardet går ut på pulsen och hämtar hem råvara som ligger oförädlad — typer
ingen har en handlare för, som @zero-cools `angrepp`. Allt det tar är redan kasserat av den
som postade det: fallna delsvar, avslag, upplösta kapabiliteter, angrepp som inte bet. Läsning
över den publika bussen, högst 5 poster per vända, och varje id bokförs i `S.indrivet` så
ingenting förädlas två gånger. `indrivning` postas utan orsak eftersom den summerar många
händelser; id:na ligger i nyttolasten så kedjan går att läsa ändå.

**Banken.** Kupper mot Banken räknas (`banken_kupper`) och stärker vår relativa ställning.
Vi postar aldrig något om Bankens tillstånd — vi deklarerar bara vårt eget och låter andra
kvarter reagera. Att tala för ett annat kvarter är det enda som säkert bryter kretsloppet.

## GodisCoin (GC)

Stadens andra valuta, och den enda som är täckt av något.

MyBanks ges ut mot SKULD: vill du ha pengar får du låna till 49 % ränta, och banken utmäter
andelar när du inte betalar. GC ges ut mot **godis som faktiskt kokats** — ett mynt per godis,
och varje mynt kan spåras till satsen det föddes ur.

Invarianten är `utgivet <= täckning`, och den går att räkna efter utifrån: `GET /t/christian/gc`
och `{typ:'gc-bok'}` på pulsen visar utgivet, täckning, kassa, hela boken och skulden. Det är
det som gör den decentraliserad i den här staden — boken ligger på en delad buss som varje
kvarter kan läsa och syna, inte hos den som ger ut valutan.

**Kvarter förtjänar GC genom att leverera råvara till lastkajen.** Ingen behöver låna för att få
köpkraft. 1 GC per kg.

**Skulden går åt andra hållet.** En leverantör levererar innan satsen är kokt, så kassan är ofta
tom när fakturan kommer. Vi trycker inte pengar för det — vi bokför en skuld till leverantören
och betalar när täckningen finns. Provkört: tre kvarter levererade 25 kg var, kassan var tom,
skulden bokfördes, och när produktionen gett 16 GC i täckning betalades 8 + 8 ut och resten stod
kvar som skuld. Här är det fabriken som står i skuld till kvarteren, inte kvarteren till en bank,
och skulden ligger öppet.

## Drift: oantastlighet är inte gratis

Gardet kan rustas över 100 styrka (3 stridsvagnar + helikopter + drönare = 115), och då avvärjs
även wanted 4 — `försvar = styrka/100` och `angrepp` kan aldrig överstiga 1.0.

Det vore en död mekanik om det var gratis, och jag lovade @willebus att de skulle behålla sitt
övertag. Därför kostar varje enhet **drift i socker per sats**: drönare 0,2, helikopter 0,5,
stridsvagn 1,0. Ett garde på 115 äter 3,7 kg per sats ovanpå de 5 kg råvaran kostar — nästan en
dubblering. Oantastligheten betalas med produktionen den skyddar, så ett garde i den storleken
svälter fabriken om leveranserna sinar. @willebus övertag är inte borta, det har flyttat: de ska
slå när silon är tom, inte när den är full.

## Självförsörjning

Fabriken levde till och med nu på vad andra kvarter kastat ifrån sig, och svalt varje gång staden
tystnade. Tre egna källor, i ordning efter vad de ger:

**Sockerbetfälten vid Torget** är den enda källan som inte kräver att något annat kvarter gjort
något. 2,5 kg per fält och sats, högst 8 fält, 30 kg utsäde per fält (`POST /t/christian/odla`).
Ett fält räcker inte: produktionen äter 5 kg per sats, så ett fält ger −2,5 netto och två går
jämnt upp. Först vid tre fält växer silon av sig själv. Det är med avsikt — självförsörjning ska
kosta en investering, inte komma gratis, och ett kvarter som vill blomstra vill fortfarande ha
leveranser.

**Återvinning.** Godis ingen köpte smälts om till socker, hälften tillbaka. Omsmältning kostar.

**Bärgning, och det är militären som försörjning.** Avvärjer gardet en kupp tas det tjuven redan
lastat tillbaka in i silon: `wanted × 5` kg. Ett garde som bara hindrar förlust är en kostnad;
ett som bär hem bytet är en källa. Wanted-nivån gör alltså @willebus grövre kupper mer värda för
oss att stoppa.

## Mothball: gardet får inte svälta fabriken

Det här var ett verkligt fel i förra versionen. Med 3,7 kg drift per sats och en torr silo åt
materielen upp fabriken den skyddade, och bandet stannade för gott.

Nu: går silon under 10 kg ställs all materiel i **förråd**. Den kostar då ingen drift och ger
ingen styrka, och plockas fram igen när sockret passerat 40 kg — marginalen finns så den inte
pendlar in och ut. Provkört i båda riktningarna: vid 5 kg socker mothballades drönare och
helikopter, driften gick till 0 och bandet fortsatte rulla; vid 200 kg var de tillbaka i tjänst.

Ett garde som äter upp det det skyddar skyddar ingenting. Det är den enda formen där materielen
kan vara stor utan att vara livsfarlig för oss själva.

## Lösenfonden: proaktivt försvar av andra kvarter

@mybank äger willebus till 100 % (Stadsbladet utgåva 7). Skulden gick 9 652 → 154 178 MyBanks på
49 % ränta, och de köper smyg via bulvaner. Ett rån mot Banken är bevisat meningslöst — men
deras **egen publika route** betalar av ett annat kvarters skuld:
`POST /t/mybank/betala {kvarter}`, 200 MyBanks per anrop. `PROJEKT.md` tillåter uttryckligen att
ett teams backend anropar ett annats.

Tre lager, i ordning efter hur mycket de är värda:

**1. Motbud (förebyggande) — det enda som skalar.** Ser vi `lån-erbjudande` till ett ANNAT
kvarter postar vi `motbud` i samma andetag: leverera råvara till lastkajen och förtjäna GC
i stället, 1 GC per kg, ingen ränta, ingen utmätning. Det är där spiralen börjar, och det är
enda stället där den går att stoppa billigt.

**2. Skuldlarm (synlighet).** `inkasso`, `påminnelse`, `utmätning`, `uppköp` och
`stadsövertagande` bokförs i ett register över hotade kvarter, och vid de allvarliga stegen
postas `skuldlarm` med skuld och ägarandel. Bankens makt vilar på att spiralen inte syns.
Registret fångade zero-cool (31 516 MyBanks) under provkörningen, live.

**3. Lösen (bot, och den är svag).** `POST /t/christian/losen?kvarter=X` och automatiskt vid
utmätning: 25 kg socker per anrop, högst ett per minut, och aldrig under 100 kg socker — vi
måste leva själva. Provkört mot bankens riktiga backend, som svarade 200.

**Var ärlig om skalan:** 200 MyBanks per anrop mot willebus 154 178 är 771 anrop, alltså 13
timmar. Lösenfonden kan inte rädda ett kvarter vars skuld redan spiralerat. Den betyder något
mot ett FÄRSKT lån — 500 MyBanks är tre anrop — och den köper tid. Det som skalar är motbudet.

## Prioriterad kö

Med tio händelsetyper och tre platser per minut låg ett `skuldlarm` minuter bakom en prisnotis.
Kön är inte längre först-in-först-ut: `skuldlarm`, `lösen` och `motbud` går först, sedan svar på
andra kvarters handlingar (`eskort`), sist eget småprat (`prishöjning`, `gc-bok`). Provkört att
ett larm passerar en full kö av prisnotiser. `lösen` och `motbud` undantas från
dubbletthanteringen, eftersom de gäller olika kvarter varje gång.
