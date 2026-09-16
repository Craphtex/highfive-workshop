---
name: spore-related
description: Find spores related to a specific spore by domain, pattern, or reference
---

# /spore related

Find spores connected to a given spore through shared domain,
similar gene patterns, direct references, or contradictions.

## Usage

```
/spore related <spore-id>               Find all related spores
/spore related <spore-id> --type <type>  Filter by relationship type
/spore related <spore-id> --deep         Follow chains (related-to-related)
```

## Standard lookup

```
/spore related aggressive-auth-001

RELATED TO: aggressive-auth-001 (graveyard)
Pattern: aggressive > 0.7 AND defensive < 0.3
Domain: authentication
────────────────────────────────────────────

SAME DOMAIN (authentication):
  - jwt-short-expiry [graveyard] Different failure, same domain
  - no-refresh-token [graveyard] Another auth pitfall
  - balanced-auth-validator [genome] Successful alternative
  - secure-session-handler [genome] Another working approach

SIMILAR GENE PATTERN:
  - aggressive-api-handler [graveyard] Same aggression/defense imbalance, API domain
  - reckless-db-query [graveyard] Similar trait combo, databases
  - speed-over-safety-003 [graveyard] Same root cause, testing domain

REFERENCES THIS SPORE:
  - timeout-cascade-002 [graveyard] Mentions this as contributing factor
  - auth-review-process [governance] Created partly in response to this pattern

CONTRADICTS:
  - fast-prototype-auth [genome] Claims aggressive works for throwaway auth code
    Resolution: Context-dependent. Aggressive fails for production, may work for prototypes.

DERIVED FROM:
  - None (this is an original observation)

5 most relevant (by connection score):
  1. balanced-auth-validator (same domain + alternative approach)
  2. aggressive-api-handler (same pattern + different domain)
  3. reckless-db-query (same pattern + different domain)
  4. fast-prototype-auth (direct contradiction)
  5. timeout-cascade-002 (references this)
```

## Filtered by type

```
/spore related aggressive-auth-001 --type contradicts

CONTRADICTIONS FOR: aggressive-auth-001

  fast-prototype-auth [genome, colony-delta, confidence: 0.55]
    Claims: aggressive > 0.8 works fine for prototype auth
    Their evidence: 4 successful evolutions in throwaway contexts
    Our evidence: 11 failures in production contexts
    
    Likely resolution: Context-dependent pattern.
    aggressive-auth-001 applies to production.
    fast-prototype-auth applies to prototypes.
    
    Both can coexist in known-bad-patterns with different contexts.
```

## Deep chains

```
/spore related aggressive-auth-001 --deep

RELATIONSHIP CHAIN (depth: 2)

aggressive-auth-001
  ├── balanced-auth-validator (alternative)
  │   ├── secure-token-handler (variant of balanced)
  │   └── jwt-refresh-variant (derived from balanced)
  │
  ├── aggressive-api-handler (same pattern)
  │   ├── defensive-api-pattern (alternative)
  │   └── api-timeout-cascade (related failure)
  │
  └── timeout-cascade-002 (references)
      └── auth-retry-logic (fix for cascade)

Total connected spores: 8
Domains touched: authentication, api-design
Colonies involved: alpha, beta, delta, local

This pattern's influence extends across 2 domains and 4 colonies.
```

## How relationships are determined

The librarian tracks relationships through:

1. **Domain match**: Spores in the same domain
2. **Pattern similarity**: Gene combinations with overlapping traits (within 0.2 threshold)
3. **Direct reference**: One spore's text mentions another by ID
4. **Contradiction**: Conflicting claims about the same gene pattern
5. **Derivation**: One genome is explicitly based on another
6. **Temporal**: Spores created in response to the same evolution

Connection score combines these signals to rank relevance.
