---
name: spore-peers
description: View and manage peer colonies in the SPORE network
---

# /spore peers

Manage your colony's peer relationships.

## Usage

```
/spore peers                    List all known peers
/spore peers add <repo-url>     Add a new peer
/spore peers remove <peer-id>   Remove a peer
/spore peers stats              Show reliability statistics
/spore peers info <peer-id>     Detailed info on specific peer
```

## Listing peers

Show all peers with their reliability and sync status.

Read all files in `.claude/spore/peers/` and format:

```
Known peers (3):

colony-alpha
  Repo: git@github.com:user/colony-alpha-spores.git
  Domains: authentication, api-design
  Reliability: 0.87 (41/47 integrated)
  Contribution: 0.34 (16 shared / 47 pulled)
  Last sync: 2 hours ago

colony-beta
  Repo: git@github.com:other/colony-beta-spores.git
  Domains: testing, databases
  Reliability: 0.92 (23/25 integrated)
  Contribution: 0.52 (13 shared / 25 pulled)
  Last sync: 1 day ago

colony-gamma [PROBATION]
  Repo: git@github.com:third/colony-gamma-spores.git
  Domains: frontend
  Reliability: 0.52 (13/25 integrated)
  Contribution: 0.00 (0 shared / 25 pulled) [PARASITIC]
  Last sync: 3 days ago
  Warning: Reliability below threshold (0.6)
  Warning: Zero contribution after 45 days (grace period: 30)
```

## Adding a peer

1. Validate repo URL format
2. Attempt to clone/fetch to verify access
3. Create peer file in `.claude/spore/peers/`
4. Set initial trust_level to "standard"
5. Set initial reliability to null (no data yet)

```
/spore peers add git@github.com:new/colony-spores.git

Checking repository access... OK
Scanning available spores... Found 34 spores
  - 20 graveyard
  - 12 genome
  - 2 fitness

Peer added: colony-new
Run /spore pull colony-new to fetch spores.
```

## Removing a peer

1. Confirm removal
2. Delete peer file
3. Optionally: remove integrated spores from this peer

```
/spore peers remove colony-gamma

Remove colony-gamma from peers? 
They have contributed 13 integrated spores.

Options:
[A] Remove peer, keep their spores
[B] Remove peer and their spores
[C] Cancel

> A

Removed colony-gamma from peers.
Their 13 spores remain in integrated/.
```

## Statistics

Show aggregate network stats:

```
/spore peers stats

Network statistics:
  Total peers: 3
  Total spores received: 97
  Integration rate: 79% (77/97)
  
By peer:
  colony-alpha:  87% (41/47)
  colony-beta:   92% (23/25)
  colony-gamma:  52% (13/25) [BELOW THRESHOLD]

Pattern diversity:
  Most common: "defensive-testing" (34%)
  Second: "balanced-api" (22%)
  Concentration risk: LOW

Recommendations:
  - Consider removing colony-gamma (reliability too low)
  - Network diversity is healthy
```

## Peer file template

When adding a peer, create this file:

```yaml
---
id: peer-id-from-repo-name
repo: git-url
domains: []  # populated after first sync
trust_level: standard
reliability: null
stats:
  received: 0
  integrated: 0
  rejected: 0
  quarantined: 0
last_sync: null
added: ISO-8601-timestamp
---

# Notes

Added on [date]. No sync yet.
```
