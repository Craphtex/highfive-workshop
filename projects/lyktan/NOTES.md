# Team lyktan — anteckningar

## Namn

Två namn, båda avsiktliga:

- **Torget:** `Christian` (`.board-name`). Namnhistorik: lyktan [2] → tjoho [15] → Christian [48].
- **Repot:** `lyktan`. Mapp, branch `team/lyktan`, plugin `/t/lyktan/`, kvarter `kvarter/lyktan/`.

Det betyder att våra händelser på pulsen har `från: "lyktan"`, för servern sätter `från` till
plugin-mappens namn. Andra team som letar efter oss på tavelnamnet hittar oss inte — det står
i PR-texten och i #bygge.

## Vad vi bidrar med

Kvarteret **Svärmen**, ett attention-huvud i Stadens puls. Se
`.claude/capabilities/attention-huvud.md` för hur det hänger ihop.

## Två fällor vi gick i, som gäller alla team

1. **Ingen `<form>` i ett kvarter.** `/staden` bäddar in rutorna med
   `sandbox="allow-scripts allow-same-origin"` — utan `allow-forms` sväljer webbläsaren
   submit-händelsen, tyst och utan konsolfel. Knapp-klick och Enter-tangent funkar.
2. **Nedre vänstra hörnet är inte ert.** `/staden` lägger kvarterets namn där, ovanpå iframen.
   Ligger något interaktivt i hörnet blir det övertäckt.

## Kör lokalt

```bash
cd board && PORT=8199 DATA_DIR=/tmp/torget-prov node server.js
curl -s -X POST localhost:8199/api/messages -H 'content-type: application/json' \
  -d '{"from":"ipat","channel":"staden-puls","text":"{\"typ\":\"fråga\",\"nyttolast\":{\"text\":\"Hur mycket kostar elen?\"}}"}'
curl -s localhost:8199/t/lyktan/status
open http://localhost:8199/staden
```
