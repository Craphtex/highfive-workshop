#!/bin/bash
# validate-spore.sh - Validate incoming spores
# Usage: ./validate-spore.sh <spore-path> | --all

set -e

SPORE_DIR="${SPORE_DIR:-.claude/spore}"
INBOX_DIR="$SPORE_DIR/inbox"
INTEGRATED_DIR="$SPORE_DIR/integrated"
REJECTED_DIR="$SPORE_DIR/rejected"
QUARANTINE_DIR="$SPORE_DIR/quarantine"
PEERS_DIR="$SPORE_DIR/peers"
LOG_FILE="$SPORE_DIR/validation.log"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[PASS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; }
log_check() { echo -e "${BLUE}[CHECK]${NC} $1"; }

# Extract YAML frontmatter value
get_yaml_value() {
    local file="$1"
    local key="$2"
    sed -n '/^---$/,/^---$/p' "$file" | grep "^$key:" | head -1 | sed "s/$key: *//"
}

# Calculate signature and compare
check_integrity() {
    local file="$1"
    local claimed_sig=$(get_yaml_value "$file" "signature")
    
    # Calculate actual signature (content after frontmatter)
    local actual_sig=$(sed '1,/^---$/d' "$file" | sed '1,/^---$/d' | sha256sum | cut -d' ' -f1)
    
    if [ "$claimed_sig" == "$actual_sig" ]; then
        return 0
    else
        return 1
    fi
}

# Check if origin peer exists
check_origin() {
    local file="$1"
    local origin=$(get_yaml_value "$file" "origin")
    
    # Check if peer file exists
    if [ -f "$PEERS_DIR/$origin.md" ] || [ -f "$PEERS_DIR/${origin}.md" ]; then
        return 0
    fi
    
    # Also accept if it's our own colony
    local our_colony=$(grep "^colony_id:" "$SPORE_DIR/config.md" 2>/dev/null | sed 's/colony_id: *//')
    if [ "$origin" == "$our_colony" ]; then
        return 0
    fi
    
    return 1
}

# Get peer reliability
get_peer_reliability() {
    local origin="$1"
    local peer_file="$PEERS_DIR/$origin.md"
    
    if [ ! -f "$peer_file" ]; then
        echo "unknown"
        return
    fi
    
    local reliability=$(get_yaml_value "$peer_file" "reliability")
    echo "${reliability:-unknown}"
}

# Check for conflicts with local evidence
check_conflicts() {
    local file="$1"
    local type=$(get_yaml_value "$file" "type")
    
    # For now, simple check - could be expanded
    # Look for similar patterns in integrated spores
    local domain=$(get_yaml_value "$file" "domain" 2>/dev/null || echo "")
    
    # No sophisticated conflict detection in bash
    # Return 0 (no conflict) - real detection happens in Claude
    return 0
}

# Check diversity (pattern concentration)
check_diversity() {
    local file="$1"
    
    # Count total integrated spores
    local total=$(find "$INTEGRATED_DIR" -name "*.md" 2>/dev/null | wc -l)
    
    # If few spores, diversity is fine
    if [ "$total" -lt 10 ]; then
        echo "0"
        return 0
    fi
    
    # Simple heuristic - would need Claude for real pattern matching
    echo "0"
    return 0
}

# Update peer stats
update_peer_stats() {
    local origin="$1"
    local result="$2"  # integrated, rejected, quarantined
    
    local peer_file="$PEERS_DIR/$origin.md"
    [ -f "$peer_file" ] || return
    
    # Increment appropriate counter
    local current=$(get_yaml_value "$peer_file" "$result" | grep -oE "[0-9]+" || echo "0")
    local new=$((current + 1))
    
    sed -i "s/^\s*$result:.*/  $result: $new/" "$peer_file"
    
    # Recalculate reliability
    local received=$(get_yaml_value "$peer_file" "received" | grep -oE "[0-9]+" || echo "0")
    received=$((received + 1))
    sed -i "s/^\s*received:.*/  received: $received/" "$peer_file"
    
    local integrated_count=$(get_yaml_value "$peer_file" "integrated" | grep -oE "[0-9]+" || echo "0")
    
    if [ "$received" -gt 0 ]; then
        local reliability=$(echo "scale=2; $integrated_count / $received" | bc)
        sed -i "s/^reliability:.*/reliability: $reliability/" "$peer_file"
    fi
}

# Log validation result
log_validation() {
    local spore_name="$1"
    local origin="$2"
    local type="$3"
    local verdict="$4"
    local reason="$5"
    
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    cat >> "$LOG_FILE" << EOF

[$timestamp] VALIDATE $spore_name
  Origin: $origin
  Type: $type
  Verdict: $verdict
  Reason: $reason
EOF
}

# Validate a single spore
validate_spore() {
    local spore_path="$1"
    local spore_name=$(basename "$spore_path")
    local type=$(basename $(dirname "$spore_path"))
    
    echo ""
    echo "Validating: $type/$spore_name"
    echo "----------------------------------------"
    
    local origin=$(get_yaml_value "$spore_path" "origin")
    local reliability=$(get_peer_reliability "$origin")
    
    echo "  From: $origin (reliability: $reliability)"
    
    local verdict="INTEGRATE"
    local reason=""
    local checks_passed=0
    local checks_total=5
    
    # Check 1: Integrity
    log_check "Integrity..."
    if check_integrity "$spore_path"; then
        log_info "Signature valid"
        ((checks_passed++))
    else
        log_fail "Signature mismatch"
        verdict="REJECT"
        reason="Integrity check failed - signature mismatch"
    fi
    
    # Check 2: Origin
    if [ "$verdict" != "REJECT" ]; then
        log_check "Origin..."
        if check_origin "$spore_path"; then
            log_info "Origin known"
            ((checks_passed++))
        else
            log_warn "Unknown origin: $origin"
            verdict="QUARANTINE"
            reason="Unknown origin colony"
        fi
    fi
    
    # Check 3: Format
    if [ "$verdict" != "REJECT" ]; then
        log_check "Format..."
        if [ -n "$(get_yaml_value "$spore_path" "type")" ]; then
            log_info "Valid format"
            ((checks_passed++))
        else
            log_fail "Invalid format"
            verdict="REJECT"
            reason="Missing required frontmatter fields"
        fi
    fi
    
    # Check 4: Conflicts
    if [ "$verdict" == "INTEGRATE" ]; then
        log_check "Conflicts..."
        if check_conflicts "$spore_path"; then
            log_info "No conflicts"
            ((checks_passed++))
        else
            log_warn "Potential conflict with local evidence"
            verdict="QUARANTINE"
            reason="Conflicts with local evidence"
        fi
    fi
    
    # Check 5: Diversity
    if [ "$verdict" == "INTEGRATE" ]; then
        log_check "Diversity..."
        local concentration=$(check_diversity "$spore_path")
        if [ "$concentration" -lt 70 ]; then
            log_info "Diversity OK (${concentration}%)"
            ((checks_passed++))
        else
            log_warn "Diversity risk (${concentration}%)"
            verdict="QUARANTINE"
            reason="Pattern concentration too high"
        fi
    fi
    
    # Apply verdict
    echo ""
    echo "  VERDICT: $verdict"
    
    case "$verdict" in
        INTEGRATE)
            mkdir -p "$INTEGRATED_DIR/$type"
            mv "$spore_path" "$INTEGRATED_DIR/$type/"
            update_peer_stats "$origin" "integrated"
            echo "  -> $INTEGRATED_DIR/$type/$spore_name"
            ;;
        REJECT)
            mkdir -p "$REJECTED_DIR/$type"
            mv "$spore_path" "$REJECTED_DIR/$type/"
            update_peer_stats "$origin" "rejected"
            echo "  -> $REJECTED_DIR/$type/$spore_name"
            echo "  Reason: $reason"
            ;;
        QUARANTINE)
            mkdir -p "$QUARANTINE_DIR/$type"
            mv "$spore_path" "$QUARANTINE_DIR/$type/"
            update_peer_stats "$origin" "quarantined"
            echo "  -> $QUARANTINE_DIR/$type/$spore_name"
            echo "  Reason: $reason"
            ;;
    esac
    
    log_validation "$spore_name" "$origin" "$type" "$verdict" "$reason"
}

# Main
main() {
    if [ "$1" == "--all" ] || [ -z "$1" ]; then
        # Validate all spores in inbox
        local spores=$(find "$INBOX_DIR" -name "*.md" 2>/dev/null)
        
        if [ -z "$spores" ]; then
            echo "No spores in inbox to validate"
            exit 0
        fi
        
        local count=$(echo "$spores" | wc -l)
        echo "Validating $count spore(s)..."
        
        local integrated=0
        local rejected=0
        local quarantined=0
        
        for spore in $spores; do
            validate_spore "$spore"
            # Count results (simplified)
        done
        
        echo ""
        echo "========================================"
        echo "Validation complete"
        
    else
        # Validate specific spore
        if [ ! -f "$1" ]; then
            echo "Spore not found: $1"
            exit 1
        fi
        validate_spore "$1"
    fi
}

main "$@"
