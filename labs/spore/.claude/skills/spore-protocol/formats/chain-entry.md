# Chain entry format

A provenance chain entry records a single network interaction:
a colony publishing a spore, pulling a spore, or integrating a spore.

The chain is a shared append-only log. Each entry links to the
previous entry via hash, forming a Merkle chain that all peers
can independently verify.

## Entry types

**PUBLISH** - Colony made a spore available to the network.
**PULL** - Colony fetched a spore from a peer.
**INTEGRATE** - Colony accepted a spore into local knowledge.
**REJECT** - Colony rejected a spore after validation.

## Entry format

```yaml
---
entry_type: PUBLISH | PULL | INTEGRATE | REJECT
colony_id: colony that performed this action
spore_hash: sha256 of the spore content
spore_type: graveyard | genome | fitness | governance
timestamp: ISO-8601 when action occurred
previous_hash: sha256 of the previous chain entry (null for genesis)
entry_hash: sha256 of this entire entry (excluding this field)
signature: colony's signature of entry_hash
---
```

## Example entries

A publish followed by a pull:

```yaml
# Entry 1: colony-alpha publishes a graveyard spore
---
entry_type: PUBLISH
colony_id: colony-alpha
spore_hash: a1b2c3d4e5f6...
spore_type: graveyard
timestamp: 2025-02-02T10:00:00Z
previous_hash: f9e8d7c6b5a4...
entry_hash: 1a2b3c4d5e6f...
signature: colony-alpha-sig-1a2b3c...
---

# Entry 2: colony-beta pulls that spore
---
entry_type: PULL
colony_id: colony-beta
spore_hash: a1b2c3d4e5f6...
spore_type: graveyard
timestamp: 2025-02-02T14:30:00Z
previous_hash: 1a2b3c4d5e6f...
entry_hash: 7g8h9i0j1k2l...
signature: colony-beta-sig-7g8h9i...
---
```

## Independence verification

The chain enables temporal independence checks for corroboration.

When colony-beta claims to independently confirm a pattern that
colony-alpha also reported, the validator checks:

1. When did colony-alpha PUBLISH the original spore?
2. When did colony-beta PULL that spore (or any related spore)?
3. When did colony-beta PUBLISH their confirmation?

If colony-beta's confirmation was published BEFORE they pulled
colony-alpha's original, it's genuinely independent. Full
corroboration bonus.

If colony-beta pulled the original BEFORE publishing their
confirmation, their observation may have been influenced.
No corroboration bonus, but no penalty either.

If there's no PULL record at all, and the claims match, it
could be independent or it could be out-of-band influence
(learned via Slack, email, etc). Partial bonus at best.

## Chain verification

Any colony can verify the chain by:

1. Fetching the full chain from the shared repo
2. Recomputing each entry_hash from entry contents
3. Verifying each previous_hash links to the prior entry
4. Verifying each signature against the colony's known public key
5. Checking for gaps (missing entries between known hashes)

A tampered entry breaks the hash chain from that point forward.
Rewrites are detectable by any honest node.

## Chain storage

The chain lives in a shared git repo, separate from any colony's
spore repo. All participating colonies have write access to append
new entries. No colony can edit or delete existing entries (enforced
by branch protection rules).

Location: configured in `config.md` under `chain.repo`.
Local cache: `.claude/spore/chain/`

## Lightweight design

This is not a cryptocurrency blockchain. There is no mining,
no proof-of-work, no tokens, no smart contracts. It's a signed
append-only log with hash linking. The "consensus mechanism" is
simple: every colony appends their own entries, and every colony
can verify everyone else's entries. Conflicts (two entries claiming
the same previous_hash) are resolved by timestamp, with both
branches preserved.

The overhead is small: one entry per publish, pull, or integrate
action. A colony exchanging 50 spores per week generates roughly
150 chain entries per week (publish + pull + integrate for each).
Each entry is a few hundred bytes.
