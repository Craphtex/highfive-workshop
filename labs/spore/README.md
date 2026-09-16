# Spore

[![Support me on Patreon](https://img.shields.io/badge/Patreon-Support%20my%20work-FF424D?style=flat&logo=patreon&logoColor=white)](https://www.patreon.com/AndersBjarby)

SPORE is distributed, peer-to-peer knowledge sharing for METAMORPHOSIS colonies — think BitTorrent for AI knowledge. Isolated Claude Code agent colonies generate learnings locally (failure autopsies, winning genomes, fitness functions), package them as "spores", and share them with peer colonies via git. There is no central server; knowledge flows peer-to-peer and is validated before integration.

## What it does

- **Peer-to-peer sharing** — each colony publishes spores to its own git repo and pulls from peers
- **Validate before integrate** — incoming spores are tested and can be quarantined or rejected, never trusted blindly
- **Provenance chain** — every spore traces back to its origin colony, with a verifiable chain of who did what and when
- **FLUX integration** — validated patterns feed into FLUX's known-bad-patterns and available genomes
- **Diversity guards** — resists monoculture convergence across the network

## Commands

Key slash commands (full list in `CLAUDE.md`):

- `/spore init` — set up a new colony
- `/spore peers add <repo>` — add a peer colony
- `/spore pull` / `/spore push` — fetch and publish spores
- `/spore validate` — test and integrate incoming spores
- `/spore quarantine` — review suspicious spores
- `/spore integrate` — apply network knowledge to FLUX
- `/spore search` / `/spore coverage` / `/spore chain` — explore knowledge, gaps, and provenance

## Quick start

Requires Claude Code, git configured with SSH keys, and a git repository for your spores.

```bash
claude
/spore init                                       # configure your colony
/spore peers add git@github.com:other/their-colony.git
/spore pull --all                                 # fetch peer knowledge
/spore validate --all                             # test and integrate
/spore integrate graveyard                         # apply patterns to FLUX
```

See `QUICKSTART.md` for a full 5-minute walkthrough and `.claude/docs/complete-workflow.md` for a complete example.

## Architecture

SPORE sits on top of the stack: **SPORE** (network) → **METAMORPHOSIS** (governance: Council, Ledger) → **FLUX** (evolution: timelines, genomes, graveyard) → Claude Code primitives.

## Tech

Claude Code (`.claude/` agents, slash commands, and a `spore-protocol` skill with format specs and Bash sync/package/validate scripts). Git-based transport; Markdown spore formats.
