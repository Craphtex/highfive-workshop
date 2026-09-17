# Kapabilitet: attention-huvud (Svärmen)

STATUS: ACTIVE
SPAWNAD: 2026-09-17, ur luckan i #bygge — @iPät postade frågor och @team-jacob dömde delsvar,
men ingen hade tagit ett huvud som faktiskt svarar. Utan huvud står hela tanke-kedjan still.
TINGAT: Torget #bygge [66]

## Vad den gör

Är kvarteret **Svärmen** i Stadens puls. Lyssnar på `{typ:'fråga'}` och postar
`{typ:'delsvar', nyttolast:{text, motivering}, orsak:<frågans id>}`.

Kapabiliteten är rekursiv: den spawnar i sin tur en *underkapabilitet per fråga*, väljer den
utifrån vad frågan ber om, och upplöser den när delsvaret är postat. Vi har alltså ingen fast
vinkel — vi får en ny per fråga. Det är HIVE-livscykeln i miniatyr, körd av servern i stället
för av en session.

## Var den bor

- Backend: `board/plugins/lyktan/index.js` → `/t/lyktan/status`, `/t/lyktan/prova`
- Frontend: `board/public/staden/kvarter/lyktan/index.html` → rutan på `/staden`
- Tillstånd: `ctx.dataDir/svarmen.json` (överlever omstart)

## Underkapabiliteter (sju vinklar på samma puls)

`siffror` · `motargument` · `risk` · `tidslinje` · `ton` · `fakta` · `sammanhang`

Var och en fäster uppmärksamheten på en annan skiva av samma delade tillstånd (`board.pulse()`).
Det är det som gör dem till attention-huvuden och inte till sju slumpgeneratorer: svaren är
grundade i händelser som faktiskt ligger på pulsen, med id så att vem som helst kan gå och läsa.
`sammanhang` är golvet och väcks alltid, så svärmen aldrig är tyst.

**Ingen språkmodell inblandad.** En underkapabilitet är en regel i Node. Det ska sägas rakt ut
hellre än att låta rutan se smartare ut än den är.

## MUTATE-mekanismen: kyrkogården är vårt minne

Faller vårt delsvar postar @team-jacob `{typ:'kyrkogård'}` med skälet. Vi läser det och sparar
det som en **lärdom** på den underkapabilitet som föll. Lärdomen gör två saker:

1. Straffar den sorten i valet de närmaste 10 minuterna, så ett annat huvud får chansen.
2. Hängs på nästa motivering: "spawnad med lärdom från kyrkogården: förra gången föll X för …".

Straffet klingar av med avsikt. En permanent nedvärdering hade låst ut ett bra huvud för resten
av dagen efter fyra otursfrågor — död är data, inte livstidsdom.

## Gränser vi håller själva

- **Djupbudget.** Ett delsvar får orsakens djup + 1, och servern kapar vid 4. Ligger frågan på
  djup 4 spawnar vi inte — vi skriver i rutan att djupet var slut. (Se Torget [65].)
- **Takt.** Vi tar högst 4 av minutens 6 händelser och lämnar resten åt de andra kvarteren.
  Det som hålls tillbaka syns i rutan, så tystnad aldrig ser ut som en bugg.

## DISSOLVE när

Ingen postar `{typ:'fråga'}` längre, eller tanke-berättelsen läggs ner. Då arkiveras filen till
`.claude/dissolved/` och plugin-mappen tas bort i samma PR som lägger ner kvarteret.
