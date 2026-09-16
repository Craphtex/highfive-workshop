---
name: spore-pull
description: Fetch new spores from peer colonies
---

# /spore pull

Fetch spores from your peer network.

## Usage

```
/spore pull                  Pull from all peers
/spore pull <peer-id>        Pull from specific peer
/spore pull --domains auth   Pull only auth-related spores
```

## Process

For each peer:

1. Read peer config from `.claude/spore/peers/[peer-id].md`
2. Fetch latest from their repo
3. Compare with already-received spores
4. Download new spores to `.claude/spore/inbox/`
5. Update last_sync timestamp

## Implementation

```bash
# For each peer in peers/
cd /tmp/spore-sync
git clone --depth 1 $PEER_REPO peer-$PEER_ID

# Find new spores (not already in inbox, integrated, or rejected)
for spore in peer-$PEER_ID/**/*.md; do
  spore_id=$(basename $spore .md)
  if [ ! -f inbox/*/$spore_id.md ] && \
     [ ! -f integrated/*/$spore_id.md ] && \
     [ ! -f rejected/*/$spore_id.md ]; then
    cp $spore inbox/$(get_type $spore)/
  fi
done

# Cleanup
rm -rf /tmp/spore-sync
```

## Output

```
/spore pull

Pulling from 3 peers...

colony-alpha (last sync: 2h ago)
  Fetching... 3 new spores
  - graveyard/aggressive-auth-001.md
  - graveyard/timeout-cascade-002.md  
  - genome/balanced-validator-003.md

colony-beta (last sync: 1d ago)
  Fetching... 1 new spore
  - fitness/multi-objective-security.md

colony-gamma (last sync: 3d ago)
  Fetching... 0 new spores
  (no updates)

Summary:
  4 new spores in inbox/
  Chain entries appended: 4 PULL entries (if chain enabled)
  
Run /spore validate to process them.
```

## Filtering by domain

Only pull spores matching specific domains:

```
/spore pull --domains authentication,security

Filtering for domains: authentication, security

colony-alpha: 2 matching spores
colony-beta: 1 matching spore
colony-gamma: 0 matching spores

3 new spores in inbox/
```

## Error handling

```
/spore pull colony-unknown

Error: No peer found with id 'colony-unknown'
Known peers: colony-alpha, colony-beta, colony-gamma

/spore pull colony-alpha

Error: Could not fetch from colony-alpha
Repository access denied or network unavailable.
Last successful sync: 2025-02-01T10:30:00Z
```

## What this does NOT do

- Validate spores (use /spore validate)
- Auto-integrate anything
- Modify your local knowledge base
- Push any data to peers

Pull is read-only and safe. Validation happens separately.
