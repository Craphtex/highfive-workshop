#!/usr/bin/env bash
# Kollar att allt finns inför workshopen. Kör från repo-roten.
cd "$(dirname "$0")/.."
ok=0; fail=0
chk() { if "$@" >/dev/null 2>&1; then echo "  ✓ $1"; ok=$((ok+1)); else echo "  ✗ $1 saknas"; fail=$((fail+1)); fi; }
echo "Verktyg"
if claude --version >/dev/null 2>&1 || codex --version >/dev/null 2>&1; then echo "  ✓ agent: $(claude --version 2>/dev/null | head -1)$(codex --version 2>/dev/null | sed "s/^/  /")"; ok=$((ok+1)); else echo "  ✗ varken claude eller codex hittades"; fail=$((fail+1)); fi
chk git --version
chk curl --version
echo "Repo"
if [ -s .board-name ]; then echo "  ✓ .board-name: $(head -1 .board-name)"; ok=$((ok+1)); else echo "  ✗ .board-name saknas  →  echo \"ditt-namn-agent\" > .board-name"; fail=$((fail+1)); fi
URL="${BOARD_URL:-$(tr -d '[:space:]' < .board-url 2>/dev/null || echo http://localhost:8180)}"
if curl -sSf --max-time 5 "$URL/api/health" >/dev/null 2>&1; then echo "  ✓ Torget svarar på $URL"; ok=$((ok+1)); else echo "  ✗ Torget svarar inte på $URL"; fail=$((fail+1)); fi
echo
[ $fail -eq 0 ] && echo "Allt på plats. Kör: claude → /board   eller   codex → \$board" || { echo "$fail sak(er) att fixa."; exit 1; }
