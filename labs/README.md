# Labs

Fyra sätt att organisera agenter. Alla är byggda som Claude Code-projekt: markdown-agenter och slash-kommandon under `.claude/`. Inget att installera.

De tre första är det ditt team är byggt av. `tools/new-team.sh <namn> factory|hive|flux` kopierar systemet till `projects/<namn>/`, så övningarna nedan gör du i din egen teammapp. Vill du prova ett system rent, utan teamuppdraget, går det också: `cd labs/<namn> && claude` (eller `codex`).

Läs `CLAUDE.md` först, det är hela manualen. Räkna med 30 minuter per system. Målet är inte att bli klar, målet är en insikt du kan säga högt i `#torget` efteråt.

## 1 · Agent Factory — agenter som rekryterar agenter

Två kärnagenter, CEO och HR. CEO intervjuar dig om vad du vill bygga, HR tar fram tre kandidater per roll (specialist, generalist, innovatör), du intervjuar och väljer. Vinnaren installeras i `.claude/agents/`. Alla agenter kan senare be HR om nya kollegor.

**Övning:** `/start` och beskriv ett kvarter du vill bygga i Staden. Låt CEO rekrytera teamet. Titta på de tre kandidaterna för samma roll: vad skiljer dem, och vilken hade du aldrig skrivit själv?

**Kommandon:** `/start`, `/recruit`, `/team`. Nya agenter kräver omstart av Claude Code.

## 2 · HIVE — förmågor i stället för roller

Ingen CEO, ingen hierarki. Förmågor spawnar när de behövs, får energi när de används, tappar energi när de ligger stilla och löses upp under 10. Överlappande förmågor smälter samman, överbelastade splittras. Det som löses upp hamnar i `.claude/dissolved/` och kan återuppstå.

**Övning:** `/awaken`, sedan `/spawn` två förmågor för samma kvarter som i lab 1. Jobba lite, kör `/evolve` och se vad HIVE föreslår. Jämför med Agent Factory: vad förlorade du när rollerna försvann, vad vann du?

**Kommandon:** `/awaken`, `/spawn`, `/status`, `/evolve`, `/dissolve`.

## 3 · FLUX — evolution över parallella tidslinjer

Inga agenter alls. Genom (personlighetsgener som `aggressive`, `cautious`, `creative` plus domängener som `testing`, `security`) sätts ihop till tidslinjer som tävlar. Fitness avgör. Riskabla gener kräver skyddsgener. Kyrkogården minns *i vilken kontext* något dog, så samma gen kan vara dödlig för säkerhetskod och utmärkt för prototyper.

**Övning:** `/explore "ett kvarter i Staden som ..."`. Titta på vilken kontext FLUX detekterar och vilka tidslinjer den forkar. Kör `/evolve` ett par generationer, `/cross` två lovande, `/select`. Läs vad som hamnade i kyrkogården och varför.

**Kommandon:** `/explore`, `/evolve`, `/status`, `/cross`, `/select`, `/terminate`, `/resurrect`.

## 4 · Spore — kolonier som delar lärdomar (avancerat, frivilligt)

Det FLUX lär sig lokalt (autopsier, vinnande genom, fitnessfunktioner) paketeras som "sporer" och delas peer-to-peer via git. Ingen central server. Inkommande sporer valideras och kan sättas i karantän. Varje spor har en spårbar härkomst.

Spore förutsätter FLUX-stacken och ett eget git-repo per koloni, så det är för mycket att köra skarpt på 30 minuter.

**Övning:** Läs `QUICKSTART.md` och formatet i `.claude/skills/spore-protocol/formats/graveyard-spore.md`. Skriv sedan *för hand* en graveyard-spore om något ni lärde er i lab 3 och posta den i `#torget`. Torget är i praktiken en central variant av samma idé: vad vinner man på att ta bort centralen?

## Efteråt

Posta en rad i `#torget`: vilket lab, vilken insikt. Det är råmaterialet till block 2.
