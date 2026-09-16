#!/bin/bash
# sync-peers.sh - Fetch spores from peer colonies
# Usage: ./sync-peers.sh [peer-id | --all]

set -e

SPORE_DIR="${SPORE_DIR:-.claude/spore}"
PEERS_DIR="$SPORE_DIR/peers"
INBOX_DIR="$SPORE_DIR/inbox"
TEMP_DIR="/tmp/spore-sync-$$"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Create temp directory
mkdir -p "$TEMP_DIR"
trap "rm -rf $TEMP_DIR" EXIT

# Get list of peers to sync
get_peers() {
    if [ "$1" == "--all" ] || [ -z "$1" ]; then
        # All peers
        find "$PEERS_DIR" -name "*.md" ! -name "_*" -exec basename {} .md \;
    else
        # Specific peer
        if [ -f "$PEERS_DIR/$1.md" ]; then
            echo "$1"
        else
            log_error "Peer not found: $1"
            log_info "Known peers:"
            find "$PEERS_DIR" -name "*.md" ! -name "_*" -exec basename {} .md \;
            exit 1
        fi
    fi
}

# Extract repo URL from peer file
get_peer_repo() {
    local peer_id="$1"
    grep "^repo:" "$PEERS_DIR/$peer_id.md" | sed 's/repo: *//'
}

# Extract value from YAML frontmatter
get_frontmatter_value() {
    local file="$1"
    local key="$2"
    sed -n '/^---$/,/^---$/p' "$file" | grep "^$key:" | sed "s/$key: *//"
}

# Check if spore already exists locally
spore_exists() {
    local spore_name="$1"
    
    # Check inbox, integrated, rejected, quarantine
    for dir in inbox integrated rejected quarantine; do
        if find "$SPORE_DIR/$dir" -name "$spore_name" 2>/dev/null | grep -q .; then
            return 0
        fi
    done
    return 1
}

# Sync a single peer
sync_peer() {
    local peer_id="$1"
    local repo_url=$(get_peer_repo "$peer_id")
    local peer_dir="$TEMP_DIR/$peer_id"
    local new_count=0
    
    log_info "Syncing $peer_id..."
    log_info "  Repo: $repo_url"
    
    # Clone peer repo (shallow)
    if ! git clone --depth 1 --quiet "$repo_url" "$peer_dir" 2>/dev/null; then
        log_error "  Failed to clone repository"
        return 1
    fi
    
    # Find all spore files
    for type in graveyard genome fitness governance; do
        local type_dir="$peer_dir/$type"
        [ -d "$type_dir" ] || continue
        
        for spore_file in "$type_dir"/*.md; do
            [ -f "$spore_file" ] || continue
            
            local spore_name=$(basename "$spore_file")
            
            # Skip if already exists
            if spore_exists "$spore_name"; then
                continue
            fi
            
            # Copy to inbox
            mkdir -p "$INBOX_DIR/$type"
            cp "$spore_file" "$INBOX_DIR/$type/"
            log_info "  + $type/$spore_name"
            ((new_count++))
        done
    done
    
    # Update last_sync in peer file
    local now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    sed -i "s/^last_sync:.*/last_sync: $now/" "$PEERS_DIR/$peer_id.md"
    
    if [ $new_count -eq 0 ]; then
        log_info "  No new spores"
    else
        log_info "  $new_count new spore(s)"
    fi
    
    return 0
}

# Main
main() {
    local peers=$(get_peers "$1")
    local total_new=0
    local failed_peers=""
    
    log_info "SPORE Sync starting..."
    echo ""
    
    for peer in $peers; do
        if sync_peer "$peer"; then
            :
        else
            failed_peers="$failed_peers $peer"
        fi
        echo ""
    done
    
    # Count total new spores
    total_new=$(find "$INBOX_DIR" -name "*.md" -newer "$0" 2>/dev/null | wc -l)
    
    echo "================================"
    log_info "Sync complete"
    log_info "New spores in inbox: $total_new"
    
    if [ -n "$failed_peers" ]; then
        log_warn "Failed peers:$failed_peers"
    fi
    
    if [ $total_new -gt 0 ]; then
        echo ""
        log_info "Run /spore validate to process new spores"
    fi
}

main "$@"
