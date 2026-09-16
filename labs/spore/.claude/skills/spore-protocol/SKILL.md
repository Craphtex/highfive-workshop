---
name: spore-protocol
description: |
  Protocol for peer-to-peer knowledge exchange between METAMORPHOSIS 
  colonies. Defines spore formats, validation rules, and network 
  conventions. Use when packaging, sending, receiving, or validating 
  distributed learnings.
---

# SPORE Protocol v1.0

## Overview

SPORE enables METAMORPHOSIS colonies to share learnings without 
central coordination. Knowledge flows peer-to-peer via git repos.

## Relationship to METAMORPHOSIS

SPORE is the network extension of concepts introduced in METAMORPHOSIS:

**Pattern plasmids -> Spores.** METAMORPHOSIS introduced horizontal 
gene transfer via plasmids between timelines within a colony. SPORE 
extends this to inter-colony transfer. Plasmids spread patterns 
within a population. Spores spread patterns between populations.

**Council.** METAMORPHOSIS's multi-model AI + human Slack governance 
body. High-risk spore integrations (fitness, governance) may require 
Council review. Council co-evolution receives signals when network 
knowledge proves correct or incorrect locally.

**Ledger.** METAMORPHOSIS's immutable decision record. When network 
knowledge influences a local decision, the Ledger records the source 
spore, enabling Ancestry Audits across colony boundaries.

**Contextual graveyard.** FLUX introduced contextual resurrection 
where the same gene combination can be lethal in one context and 
beneficial in another. Graveyard spores support per-context risk 
profiles for this purpose.

## Network topology

No hub. Each colony maintains its own git repo. Peers pull from 
each other directly based on trust relationships defined locally.

```
Colony-A <---> Colony-B
    ^             ^
    |             |
    v             v
Colony-C <---> Colony-D
```

## Spore types

Four types of knowledge can be packaged as spores:

**graveyard** - Dead timeline autopsies. What failed and why.
See `formats/graveyard-spore.md` for schema.

**genome** - Successful gene combinations. What worked.
See `formats/genome-spore.md` for schema.

**fitness** - Evaluation functions. How to measure success.
See `formats/fitness-spore.md` for schema.

**governance** - Institutional patterns. How to organize.
Shared rarely and only on explicit request.

## Standard spore header

All spores must include this frontmatter:

```yaml
---
type: graveyard | genome | fitness | governance
origin: colony-id-that-created-this
created: 2025-02-02T14:30:00Z
confidence: 0.0 to 1.0
context:
  domain: problem-space
  constraints: limitations-that-applied
  environment: tech-stack-or-context
  model: ai-model-that-produced-this
signature: sha256-hash-of-content-below-frontmatter
forwarded_by: []  # empty if direct, list if relayed
---
```

The `model` field matters because METAMORPHOSIS supports multi-model 
evolution (Claude, GPT, Gemini). A genome's success may be partially 
model-dependent.

## Exchange protocol

### Publishing (outbound)

1. Local learning passes validation
2. Packager agent creates spore with proper format
3. Spore placed in `.claude/spore/outbox/[type]/`
4. Git add, commit, push to colony's public repo
5. Spore is now available to peers

### Subscribing (inbound)

1. Run `/spore pull` to fetch from peer repos
2. New spores land in `.claude/spore/inbox/`
3. Run `/spore validate` to process each
4. Validator moves to integrated/, rejected/, or quarantine/
5. Integrated spores become part of local knowledge

## Peer file format

Peers defined in `.claude/spore/peers/[peer-id].md`:

```yaml
---
id: colony-alpha
repo: git@github.com:user/colony-alpha-spores.git
domains:
  - authentication
  - api-design
trust_level: standard | elevated | probation
reliability: 0.87
stats:
  received: 47
  integrated: 41
  rejected: 4
  quarantined: 2
last_sync: 2025-02-01T10:30:00Z
---

# Notes

Free-form notes about this peer.
```

## Validation rules

Spores must pass these checks before integration:

1. **Integrity** - Signature matches content
2. **Format** - Follows spore schema for its type
3. **Context** - Relevant to local domains
4. **Conflict** - Does not contradict strong local evidence
5. **Diversity** - Does not push pattern concentration >70%
6. **Conservation** - Does not override protected local patterns
7. **Source** - Peer reliability above threshold
8. **Corroboration** - Cross-reference against other peers' claims

Failure modes:
- Integrity fail = REJECT (corrupted or tampered)
- Format fail = REJECT (non-compliant)
- Context fail = REJECT or lower confidence
- Conflict = QUARANTINE for review
- Diversity fail = QUARANTINE
- Conservation fail = QUARANTINE with "conflicts with conserved pattern" note
- Source fail = extra scrutiny, not auto-reject
- Corroboration: no penalty for single-source; bonus for multi-source confirmation; QUARANTINE if 3+ peers contradict

## Convergence protection

Track pattern distribution across integrated spores.

Alert triggers:
- Any single pattern in >70% of spores
- Any single peer providing >50% of knowledge
- Quarantine queue growing faster than integration

Response options:
- Resurrect minority patterns
- Seek diverse peers
- Deliberately evolve against dominant pattern

## Conservation areas

METAMORPHOSIS protects biodiversity by allowing timelines to reject 
viral pattern infection. SPORE extends this to the network level.

Local patterns can be marked as "conserved" in config. Conserved 
patterns are not overridden by network integrations, even when 
network consensus disagrees. This preserves minority approaches 
that may prove valuable under future conditions.

When a spore conflicts with a conserved pattern, it goes to 
quarantine rather than being integrated automatically.

## Freshness

Knowledge decays. Spores have a configurable max age, after which 
they are flagged for revalidation. If auto_deprecate is enabled, 
stale spores gradually lose confidence.

This addresses the question of how network knowledge stays current. 
A graveyard pattern from six months ago may no longer apply if the 
underlying tools or practices have changed.

## Corroboration

Independent confirmation from multiple peers strengthens confidence.
The librarian maintains a corroboration index tracking how many 
unrelated sources confirm each claim.

Confidence adjustments:
- 0 other sources: +0.00 (no data either way)
- 1 other source: +0.03
- 2 other sources: +0.06
- 3+ other sources: +0.10
- 1 contradiction: -0.05
- 2 contradictions: -0.10
- 3+ contradictions: QUARANTINE

This is the primary defense against subtly degraded knowledge.
A parasitic peer sharing "junk" that almost-but-not-quite works 
finds their claims unsupported by honest peers. Independent 
confirmation is stronger evidence than any single observation.

## Reciprocity

SPORE tracks whether peers contribute as well as consume.

```
contribution_ratio = spores_shared / spores_pulled
```

New peers start at 0.0 and get a grace period (default 30 days)
before the ratio matters. After the grace period, peers below 
min_contribution_ratio (default 0.1) get flagged as parasitic.

The protocol does not automatically punish parasitic peers.
It surfaces the information to the operator. The human decides:
maybe the peer is new, maybe they work in a niche domain with
less to share, maybe they're genuinely free-loading. Context
matters more than ratios.

If warn_only is false, the colony automatically restricts sharing
with parasitic peers (still pulls from them, stops pushing to them).

## Provenance chain

A shared append-only log that records network interactions with
verifiable temporal ordering. Not a cryptocurrency blockchain.
No mining, no tokens, no proof-of-work. Just a signed hash chain
that all peers can independently verify.

### What it records

Four entry types:
- PUBLISH: colony made a spore available
- PULL: colony fetched a spore from a peer
- INTEGRATE: colony accepted a spore
- REJECT: colony rejected a spore

Each entry includes: colony ID, spore hash, timestamp, a link
to the previous entry's hash, and the colony's cryptographic 
signature. See `formats/chain-entry.md` for the full spec.

### Why it exists

The chain solves one specific problem: verifying that corroboration
is genuinely independent. Without temporal ordering, three colonies
confirming the same pattern looks like strong evidence. With temporal
ordering, you can see that two of them pulled the original before
publishing their "independent" confirmations. The corroboration
bonus adjusts accordingly.

This also detects shadow centers: if 90% of confirmations trace
back (via pull timestamps) to one original source, the network
knows its apparent consensus is actually one voice echoed.

### Independence verification

When checking corroboration:

1. Find the earliest PUBLISH entry for this pattern
2. For each confirming colony, check their PULL history
3. If they pulled the original before publishing their confirmation,
   mark as NOT INDEPENDENT (bonus: +0.00)
4. If their confirmation predates any pull of the original,
   mark as INDEPENDENT (full bonus)
5. If no chain data exists, mark as UNCERTAIN (partial bonus: +0.01)

### Chain storage

The chain lives in a separate shared git repo. All participating 
colonies append entries. No colony can edit or delete existing 
entries. Git branch protection enforces append-only semantics.

### Privacy trade-off

The chain reveals which colonies consume which knowledge.
Mitigation options in config:
- batch_pulls: log one PULL per sync instead of per spore
- delay_hours: delay entry logging
- Or opt out entirely (lose independence verification)

## Forwarding rules

Colonies can forward spores they received from others.

When forwarding:
- Keep original `origin` field
- Add self to `forwarded_by` list
- Do not modify content or signature

Reputation accrues to origin, not forwarders.

## Privacy settings

Colonies control what they share via config:

```yaml
privacy:
  share_graveyard: true
  share_genomes: true
  share_fitness: true
  share_governance: false
```

Respect these settings. Never pressure peers to share more.
