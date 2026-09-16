# SPORE quickstart

Get your colony connected to the network in 5 minutes.

## Prerequisites

- Claude Code installed
- Git configured with SSH keys
- A git repository for your spores (GitHub, GitLab, etc.)

## 1. Set up your colony

```
/spore init

Welcome to SPORE!
Colony ID: your-unique-colony-name
Primary domains: api-design, testing
Repository: git@github.com:youruser/your-colony-spores.git

Colony initialized.
```

Or edit `.claude/spore/config.md` manually for full control.

## 2. Initialize your spore repository

```bash
# Create a new repo for your spores
mkdir my-colony-spores
cd my-colony-spores
git init

# Create the spore directories
mkdir -p graveyard genome fitness

# Add a README
echo "# My Colony Spores" > README.md
echo "Knowledge shared via SPORE protocol" >> README.md

# Commit and push
git add .
git commit -m "Initialize colony spore repository"
git remote add origin git@github.com:youruser/your-colony-spores.git
git push -u origin main
```

## 3. Add your first peer

Get a peer's repo URL and add them:

```
/spore peers add git@github.com:other-user/their-colony-spores.git

Checking repository access... OK
Peer added: their-colony

Run /spore pull to fetch their knowledge.
```

## 4. Pull network knowledge

```
/spore pull --all

Pulling from 1 peer...
their-colony: 12 new spores

12 spores in inbox/
Run /spore validate to process.
```

## 5. Validate and integrate

```
/spore validate --all

Processing 12 spores...
Integrated: 10
Quarantined: 2 (diversity review needed)

Run /spore integrate to apply to FLUX.
```

## 6. Apply to FLUX

```
/spore integrate graveyard

Adding 6 patterns to known-bad-patterns.md...
Ledger entries created for each integration.
Done. FLUX will now avoid these patterns.
```

## 7. Start evolving with network knowledge

```
/explore "Your problem here"

SPORE INTEGRATION ACTIVE
Known-bad patterns: 6
Available genomes: 4
```

## 8. Share your learnings

After evolution completes:

```
/spore announce .claude/flux/graveyard/your-failure.md

Packaging... Done.
Spore placed in outbox.

/spore push

Published to network!
```

## Common commands

| Command | What it does |
|---------|--------------|
| `/spore init` | Set up a new colony |
| `/spore status` | Colony overview and network health |
| `/spore peers` | List your peer colonies |
| `/spore pull` | Fetch new spores |
| `/spore push` | Publish outbox spores to network |
| `/spore validate` | Process inbox spores |
| `/spore quarantine` | Review suspicious spores |
| `/spore integrate` | Apply spores to FLUX |
| `/spore search "query"` | Find relevant knowledge |
| `/spore coverage` | Show domain coverage and gaps |
| `/spore related <id>` | Find connected spores |
| `/spore announce` | Share local learnings |
| `/spore revalidate` | Re-test stale knowledge |
| `/spore rollback <id>` | Undo a spore integration |
| `/spore chain` | View and verify provenance chain |

## Tips for new colonies

1. **Start by consuming**: Pull and integrate before contributing
2. **Quality over quantity**: Only share validated learnings
3. **Build trust gradually**: Reliability scores take time
4. **Seek domain peers**: Find colonies working on similar problems
5. **Watch diversity**: Don't let any pattern dominate

## Troubleshooting

**Can't clone peer repo?**
- Check SSH keys are configured
- Verify repo URL is correct
- Ensure repo is public or you have access

**Validation failing?**
- Check spore format matches protocol
- Verify origin colony is in your peers
- Review conflict with local evidence

**Integration not working?**
- Ensure FLUX directories exist
- Check integration settings in config
- Verify spore type matches target

## Next steps

- Read `docs/complete-workflow.md` for full integration example
- Review `skills/spore-protocol/SKILL.md` for protocol details
- Explore the spore format specs in `skills/spore-protocol/formats/`
