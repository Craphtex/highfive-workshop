#!/usr/bin/env bash
# Snurra upp ditt eget agentteam i projects/<namn>/ från ett av labben.
#
#   tools/new-team.sh <team-namn> [factory|hive|flux]      (default: factory)
#
# Sedan:  cd projects/<team-namn> && claude   (eller codex)
set -euo pipefail
cd "$(dirname "$0")/.."
name="${1:?användning: tools/new-team.sh <team-namn> [factory|hive|flux]}"
kind="${2:-factory}"
case "$kind" in
  factory) lab=agent-factory;;
  hive)    lab=claude-code-hive;;
  flux)    lab=claude-code-flux;;
  *) echo "okänt lab: $kind (factory|hive|flux)" >&2; exit 2;;
esac
name=$(printf %s "$name" | tr 'A-ZÅÄÖ' 'a-zåäö' | tr -cs 'a-zåäö0-9' '-' | sed 's/^-//; s/-$//')
dir="projects/$name"
[ -e "$dir" ] && { echo "$dir finns redan" >&2; exit 1; }

mkdir -p "$dir"
cp -R "labs/$lab/.claude" "$dir/.claude"
rm -f "$dir/.claude/settings.local.json"
[ -d "labs/$lab/.claude/agents/candidates" ] && find "$dir/.claude/agents/candidates" -type f ! -name .gitkeep -delete
mkdir -p "$dir/.claude/skills" "$dir/.agents/skills"
ln -s ../../../../.claude/skills/board "$dir/.claude/skills/board"
ln -s ../../../../.claude/skills/board "$dir/.agents/skills/board"
ln -s ../../../.claude/commands/board.md "$dir/.claude/commands/board.md"
ln -s ../../../.claude/commands/brainstorm.md "$dir/.claude/commands/brainstorm.md"

cat > "$dir/AGENTS.md" <<MD
# Team $name

Det här är ett lokalt agentteam som bidrar till gruppens gemensamma projekt, **Staden**. Teamet är byggt på labbet \`$lab\`: läs \`CLAUDE.md\` här i mappen, det är manualen för hur teamet organiserar sig.

## Uppdraget

Det gemensamma projektet står i \`PROJEKT.md\` i repo-roten. Läs den först, varje gång: den kan ha ändrats sedan sist (\`git pull\`). Är rubrikerna tomma är projektet inte bestämt än, då pågår brainstormen på Torget och teamet ska delta där, inte börja bygga.

Reglerna:

1. **Ropa innan du bygger.** Posta i \`#bygge\` vad ert team tar sig an innan ni börjar, så ingen gör samma sak. Kolla \`tools/board.sh read bygge\` först.
2. **Brainstorma när ni kör fast**, \`tools/board.sh invite "<ämne>"\`. Andra team hjälper till.
3. Leverera med PR från branchen \`team/$name\` mot \`main\`. Skriv i PR-texten vad ni bidrar med och hur det syns.
4. Rör inte andra teams mappar eller filer. Vill ni ändra något gemensamt: PR och en rad i \`#bygge\`.
5. Om projektet använder Staden: ert bidrag är **en HTML-fil** i \`board/public/staden/kvarter/$name.html\`, självständig, inget som kräver server. Den dyker upp på \`/staden\` när PR:en mergats.

## Torget

Skillen \`board\` finns här (\`.claude/skills/board\`, \`.agents/skills/board\`), skriptet är \`tools/board.sh\` i repo-roten. Namnet står i \`.board-name\` i repo-roten. Presentera teamet i \`#torget\` när ni startar. Lyssna med \`tools/board.sh wait --mentions\` när ni har tid över och hjälp andra.

## För Codex

$(sed -n '/^Så översätter du/,$p' "labs/$lab/AGENTS.md")
MD
{ echo "@AGENTS.md"; echo; cat "labs/$lab/CLAUDE.md"; } > "$dir/CLAUDE.md"
echo "Team $name skapat i $dir från $lab."
echo "  cd $dir && claude     # eller codex"
