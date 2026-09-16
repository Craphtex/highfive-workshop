---
name: spore-search
description: Search network knowledge for relevant patterns and solutions
---

# /spore search

Find relevant knowledge from the network.

## Usage

```
/spore search "query"                    Search all integrated knowledge
/spore search "query" --type graveyard   Search only graveyard spores
/spore search "query" --domain auth      Search specific domain
/spore search --recent                   Show recently integrated spores
```

## How it works

The librarian agent searches:
1. Spore index keywords
2. Spore titles and summaries
3. Full spore content
4. Known-bad-patterns
5. Imported genomes and fitness functions

Results are ranked by relevance and confidence.

## Example searches

### Finding what fails

```
> /spore search "authentication security"

Searching network knowledge...

FAILURES TO AVOID (graveyard):

1. aggressive-auth-001 [confidence: 0.73]
   Pattern: aggressive > 0.7 AND defensive < 0.3
   Fails: Security audit
   Source: colony-alpha
   
2. jwt-validation-skip [confidence: 0.81]
   Pattern: Skipping token validation for "trusted" sources
   Fails: Produces security holes
   Source: colony-beta

3. session-not-cleared [confidence: 0.65]
   Pattern: Session persists after logout
   Fails: Security compliance
   Source: local

SUCCESSFUL APPROACHES (genomes):

4. balanced-auth-validator [confidence: 0.80]
   Traits: analytical(0.7), defensive(0.65), methodical(0.75)
   Survived: 8 generations
   Source: colony-alpha

EVALUATION METHODS (fitness):

5. multi-objective-security [confidence: 0.65]
   Balances security + functionality
   Source: colony-alpha

─────────────────────────────────────
5 results found. View details? [1-5/q]
```

### Finding solutions

```
> /spore search "timeout handling" --type genome

Searching genomes for: timeout handling

RESULTS:

1. graceful-timeout-handler [confidence: 0.75]
   Handles timeouts with exponential backoff
   Traits: defensive(0.7), methodical(0.8), cautious(0.6)
   Heritage: "Never fail silently. Retry with backoff, then 
             fail gracefully with clear error message."
   Source: colony-beta
   
2. resilient-api-client [confidence: 0.70]
   Circuit breaker pattern for external APIs
   Traits: defensive(0.75), analytical(0.65)
   Heritage: "Assume external services will fail. Build for it."
   Source: colony-gamma

─────────────────────────────────────
View full genome? [1-2/q] > 1

[Full genome details displayed]

Add to your gene pool? [Y/n]
```

### Checking if a pattern is known-bad

```
> /spore search "aggressive experimental" --type graveyard

Searching for dangerous patterns...

WARNING: This combination has known failures.

KNOWN-BAD PATTERNS:

1. aggressive-experimental-chaos [confidence: 0.85]
   Pattern: aggressive > 0.7 AND experimental > 0.8
   Context: Any production code
   Failure: Unstable, unpredictable behavior
   Observations: 17 across 4 colonies
   Action: BLOCK (high confidence)
   
2. experimental-without-testing [confidence: 0.72]
   Pattern: experimental > 0.6 AND testing-skill absent
   Context: Evolving new approaches
   Failure: No validation of novel ideas
   Observations: 9 across 3 colonies
   Action: WARN

RECOMMENDATION:
If your current evolution uses aggressive + experimental genes,
consider adding defensive or methodical traits to balance.
```

### Exploring a domain

```
> /spore search --domain databases

Knowledge in domain: databases

COVERAGE: 8 spores from 2 sources

FAILURES (graveyard): 4
- connection-pool-exhaustion (colony-alpha)
- n-plus-one-queries (colony-beta)  
- missing-indexes (local)
- transaction-deadlock (colony-alpha)

SUCCESSES (genome): 3
- defensive-query-builder (colony-alpha)
- connection-pool-manager (colony-beta)
- index-aware-queries (local)

FITNESS: 1
- query-performance-score (colony-beta)

PATTERNS IN known-bad-patterns.md: 2
- pool_size < 10 for high-traffic (warn)
- no_index on frequently-queried columns (warn)

Gap analysis:
- No spores about: migrations, replication, sharding
- Consider seeking peers who specialize in these areas
```

### Recent additions

```
> /spore search --recent

Recently integrated spores (last 7 days):

TODAY:
- aggressive-auth-001 (graveyard) from colony-alpha
- balanced-validator-003 (genome) from colony-alpha

2 DAYS AGO:
- timeout-cascade-002 (graveyard) from colony-alpha
- multi-objective-security (fitness) from colony-alpha

5 DAYS AGO:
- defensive-api-handler (genome) from colony-beta

Total: 5 spores integrated this week
From: 2 unique peers
```

## Search tips

1. **Start broad, then narrow**: Search "auth" before "jwt token refresh"
2. **Check graveyard first**: Know what fails before building
3. **Look for genomes**: Don't reinvent successful patterns
4. **Review fitness functions**: Better evaluation = better evolution
5. **Note the source**: Multiple colonies confirming = higher confidence

## Integration with evolution

Before starting a new `/explore`:

```
> /spore search "authentication api"

[Results displayed]

> /explore "Build authentication for API"

SPORE INTEGRATION:
Based on your search, I found:
- 3 patterns to avoid (added to known-bad)
- 2 genomes available as starting points
- 1 fitness function you might use

Start with imported genome? [Y/n]
```
