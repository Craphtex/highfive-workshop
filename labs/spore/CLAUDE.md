# SPORE

Distributed peer-to-peer knowledge sharing for METAMORPHOSIS colonies.

## What this is

SPORE enables isolated AI agent colonies to share learnings without central coordination. Think BitTorrent for AI knowledge.

Each colony:
- Generates learnings locally (graveyard entries, winning genomes, fitness functions)
- Packages them as "spores" with metadata
- Publishes to its own git repo
- Pulls spores from peer colonies
- Validates before integrating

No central server. Knowledge flows peer-to-peer.

## Quick start

```bash
# 1. Configure your colony
# Edit .claude/spore/config.md with your colony ID and repo

# 2. Add a peer
/spore peers add git@github.com:other/their-colony.git

# 3. Pull knowledge
/spore pull --all

# 4. Validate incoming spores
/spore validate --all

# 5. Share your learnings
/spore announce .claude/flux/graveyard/some-autopsy.md
```

## Commands

| Command | Purpose |
|---------|---------|
| /spore init | Set up a new colony |
| /spore status | Overview of network state |
| /spore peers | List and manage peer colonies |
| /spore pull | Fetch spores from peers |
| /spore push | Publish outbox spores to network |
| /spore validate | Test and integrate incoming spores |
| /spore quarantine | Review suspicious spores |
| /spore announce | Share local learning with network |
| /spore search | Find relevant spores across peers |
| /spore integrate | Apply network knowledge to FLUX |
| /spore coverage | Show domain coverage and gaps |
| /spore related | Find connected spores |
| /spore revalidate | Re-test stale knowledge |
| /spore rollback | Undo a spore integration |
| /spore chain | View and verify the provenance chain |

## Directory structure

```
.claude/
├── agents/spore/
│   ├── spore-core.md      # Network coordinator
│   ├── packager.md        # Creates spores
│   ├── validator.md       # Tests incoming spores
│   ├── librarian.md       # Indexes and searches knowledge
│   └── integration.md     # Bridges SPORE with FLUX/METAMORPHOSIS
│
├── skills/spore-protocol/
│   ├── SKILL.md           # Protocol definition
│   ├── formats/           # Spore format specs (graveyard, genome, fitness, governance, chain-entry)
│   └── scripts/           # Bash utilities (init, sync, package, validate, push, init-chain)
│
├── spore/
│   ├── config.md          # Colony settings
│   ├── index.md           # Searchable knowledge index
│   ├── peers/             # Known colonies
│   ├── inbox/             # Received, awaiting validation
│   ├── outbox/            # Ready to publish
│   ├── integrated/        # Validated and active
│   ├── rejected/          # Failed validation
│   ├── quarantine/        # Under review
│   └── chain/             # Local cache of provenance chain (if enabled)
│
├── flux/
│   └── known-bad-patterns.md  # Network patterns to avoid (with risk profiles)
│
└── commands/
    └── spore-*.md         # Slash commands
```

## Core principles

1. **No central authority.** All colonies are equal peers.
2. **Validate before integrate.** Never trust blindly.
3. **Diversity matters.** Resist monoculture convergence.
4. **Attribution persists.** Every spore traces to its origin.
5. **Record everything.** Network knowledge logged to Ledger.
6. **Provenance is verifiable.** The chain records who did what, and when.

## Integration with METAMORPHOSIS

SPORE extends concepts from METAMORPHOSIS:

**Pattern plasmids become spores.** METAMORPHOSIS introduced plasmids 
for intra-colony horizontal gene transfer. SPORE extends this to 
inter-colony transfer. Same principle, network scope.

**Council reviews high-risk integrations.** Fitness and governance 
spores may require Council (multi-model AI + human pool) approval 
before integration.

**Ledger tracks network influence.** When network knowledge shapes 
a local evolution, the Ledger records which spores contributed. This 
enables Ancestry Audits across colony boundaries.

**Contextual graveyard.** Graveyard spores support per-context risk 
profiles, matching FLUX's contextual resurrection where the same gene 
combination can fail in one context and succeed in another.

```
SPORE (network layer)
    |
METAMORPHOSIS (governance: Council, Ledger, Senate)
    |
FLUX (evolution: timelines, genomes, graveyard, plasmids)
    |
Claude Code primitives
```

## The arc

- Agent Factory: Tool (human patterns)
- HIVE: Organism (alien patterns)
- FLUX: Evolution (parallel competition)
- METAMORPHOSIS: Institution (governance)
- SPORE: Ecosystem (distributed network)

Each step removed an assumption. SPORE removes the assumption that colonies must learn alone.

*The graveyard remembers. The network spreads. The spores find fertile ground.*
