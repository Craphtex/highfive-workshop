#!/bin/bash
# Initialize or join the SPORE provenance chain
# Usage: init-chain.sh <chain-repo-url> [--create]

set -e

CHAIN_REPO="$1"
CREATE_NEW="$2"

if [ -z "$CHAIN_REPO" ]; then
  echo "Usage: init-chain.sh <chain-repo-url> [--create]"
  echo ""
  echo "  <chain-repo-url>  Git URL for the shared chain repo"
  echo "  --create          Create a new chain (genesis block)"
  exit 1
fi

CHAIN_DIR=".claude/spore/chain"

# Clone or create
if [ "$CREATE_NEW" = "--create" ]; then
  echo "Creating new provenance chain..."
  mkdir -p "$CHAIN_DIR"
  cd "$CHAIN_DIR"
  git init
  
  # Read colony ID from config
  COLONY_ID=$(grep "colony_id:" ../../config.md | head -1 | awk '{print $2}')
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  
  # Create genesis entry
  GENESIS_CONTENT="entry_type: GENESIS
colony_id: $COLONY_ID
timestamp: $TIMESTAMP
previous_hash: null
message: Chain initialized by $COLONY_ID"
  
  GENESIS_HASH=$(echo "$GENESIS_CONTENT" | sha256sum | awk '{print $1}')
  
  cat > "0001-genesis.yaml" << EOF
---
entry_type: GENESIS
colony_id: $COLONY_ID
timestamp: $TIMESTAMP
previous_hash: null
entry_hash: $GENESIS_HASH
message: Chain initialized by $COLONY_ID
---
EOF
  
  git add .
  git commit -m "Genesis: chain initialized by $COLONY_ID"
  git remote add origin "$CHAIN_REPO"
  echo ""
  echo "Chain created. Push with: cd $CHAIN_DIR && git push -u origin main"
  
else
  echo "Joining existing provenance chain..."
  
  if [ -d "$CHAIN_DIR/.git" ]; then
    echo "Chain already exists locally. Pulling latest..."
    cd "$CHAIN_DIR"
    git pull --rebase
  else
    echo "Cloning chain repo..."
    git clone "$CHAIN_REPO" "$CHAIN_DIR"
  fi
  
  ENTRY_COUNT=$(ls "$CHAIN_DIR"/*.yaml 2>/dev/null | wc -l)
  echo ""
  echo "Chain synced. $ENTRY_COUNT entries in chain."
fi

echo ""
echo "Chain location: $CHAIN_DIR"
echo "Chain repo: $CHAIN_REPO"
