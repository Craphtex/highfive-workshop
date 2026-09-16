---
name: spore-revalidate
description: Re-test stale integrated spores to confirm they still hold
---

# /spore revalidate

Knowledge decays. Patterns that were true six months ago may not
apply today. Revalidation re-tests integrated spores against current
local evidence and updates confidence accordingly.

## Usage

```
/spore revalidate --stale           Re-test all stale spores
/spore revalidate <spore-id>        Re-test a specific spore
/spore revalidate <domain>          Re-test all spores in a domain
/spore revalidate --deprecated      Show and re-test deprecated spores
/spore revalidate --dry-run         Show what would be re-tested
```

## Stale spore revalidation

```
/spore revalidate --stale

REVALIDATION: STALE SPORES
───────────────────────────

Config: max_age_days=180, revalidation_interval_days=90

Found 11 stale spores (not validated in 90+ days):

[1/11] jwt-timeout-cascade (graveyard, 147 days old)
  Original claim: JWT validation timeout < 500ms causes cascade
  Confidence was: 0.78
  
  Checking local evidence...
    Recent evolutions with JWT: 3 found
    Timeout-related failures: 1 found (confirms pattern)
    
  RESULT: CONFIRMED
  Confidence updated: 0.78 -> 0.80 (local confirmation)
  Last validated: now

[2/11] speed-over-safety-003 (graveyard, 132 days old)
  Original claim: experimental > 0.8 without methodical < 0.2 fails production
  Confidence was: 0.68
  
  Checking local evidence...
    Recent evolutions matching this pattern: 0 found
    No new evidence either way
    
  RESULT: UNCHANGED (no new evidence)
  Confidence: 0.68 (unchanged)
  Last validated: now

[3/11] balanced-api-handler-v2 (genome, 121 days old)
  Original claim: defensive + methodical genome succeeds on APIs
  Confidence was: 0.75
  
  Checking local evidence...
    Used as starting genome: 2 times since integration
    Both evolutions succeeded (fitness 78, 82)
    
  RESULT: CONFIRMED
  Confidence updated: 0.75 -> 0.82
  Last validated: now

... [8 more spores processed]

SUMMARY:
  Confirmed: 6 (confidence increased)
  Unchanged: 3 (no new evidence, kept current confidence)
  Weakened: 1 (local evidence partially contradicts)
  Deprecated: 1 (moved to deprecated, confidence below 0.3)
  
  Total time: 45 seconds
```

## Domain revalidation

```
/spore revalidate authentication

REVALIDATION: authentication domain
────────────────────────────────────

31 spores in domain, 5 stale:

[1/5] aggressive-auth-001 (graveyard, 98 days)
  CONFIRMED: 2 new local observations match pattern
  Confidence: 0.76 -> 0.79

[2/5] no-refresh-token (graveyard, 103 days)
  UNCHANGED: No new evidence
  Confidence: 0.71

[3/5] secure-session-handler (genome, 112 days)
  WEAKENED: Used once, fitness was only 62 (below expectation)
  Confidence: 0.75 -> 0.68

[4/5] auth-speed-balance (fitness, 95 days)
  CONFIRMED: 1 evolution used this function successfully
  Confidence: 0.55 -> 0.58

[5/5] balanced-auth-validator (genome, 91 days)
  CONFIRMED: Used 3 times, consistently high fitness
  Confidence: 0.80 -> 0.85

Domain health: GOOD (no deprecations)
```

## Specific spore

```
/spore revalidate jwt-timeout-cascade

REVALIDATION: jwt-timeout-cascade
──────────────────────────────────

Type: graveyard
Origin: colony-alpha
Age: 147 days
Last validated: 92 days ago
Confidence: 0.78

Original claim:
  "JWT validation timeout < 500ms causes cascade failure
   when auth service is under load. Tokens expire mid-validation,
   causing retry storms."

Checking against local evidence:

  Local evolutions involving JWT: 3
    - auth-jwt-refresh-001 (30 days ago): No timeout issues (timeout was 2000ms)
    - session-cleanup-002 (45 days ago): No JWT involvement
    - api-auth-003 (62 days ago): Timeout set to 1000ms, no cascade

  Local known-bad-patterns matching: 1
    - jwt-expiry confirmed (different but related)

  Recent network updates on this topic: 0

Assessment:
  Pattern still appears valid but local evidence is indirect
  (we've been using higher timeouts, so we haven't triggered it)

RESULT: UNCHANGED
  The pattern hasn't been contradicted, but we also haven't
  directly tested it. Keeping current confidence.

Confidence: 0.78 (unchanged)
Last validated: now

Recommendation: Could run a targeted test evolution with
  low timeout to verify. Run /explore with timeout < 500ms
  to directly test this claim.
```

## Deprecated spores

```
/spore revalidate --deprecated

DEPRECATED SPORES
─────────────────

3 spores have been deprecated (confidence fell below 0.3):

  1. old-session-pattern (genome, deprecated 14 days ago)
     Original confidence: 0.60
     Current confidence: 0.25
     Reason: 3 consecutive failures when used as starting genome
     Action: Remove from gene pool? [Y/n/skip]

  2. strict-timeout-rule (graveyard, deprecated 7 days ago)
     Original confidence: 0.55
     Current confidence: 0.28
     Reason: Pattern no longer applies after library update
     Action: Remove from known-bad-patterns? [Y/n/skip]

  3. legacy-auth-fitness (fitness, deprecated 21 days ago)
     Original confidence: 0.50
     Current confidence: 0.20
     Reason: Gaming vectors no longer relevant
     Action: Remove from fitness pool? [Y/n/skip]
```

## How revalidation works

1. Find integrated spores older than revalidation_interval_days
2. For each stale spore, search local evidence:
   - Recent evolutions that used or tested the pattern
   - Local graveyard entries that confirm or contradict
   - Known-bad-pattern hits that relate
3. Update confidence based on findings:
   - Confirmed by local evidence: increase by 0.02-0.05
   - No new evidence: unchanged
   - Partially contradicted: decrease by 0.05-0.10
   - Strongly contradicted: decrease by 0.15-0.25
4. If confidence drops below 0.3: mark as deprecated
5. Update last_validated timestamp

## Auto-deprecation

If config.freshness.auto_deprecate is true, spores that miss
revalidation cycles automatically lose confidence:

```
confidence_loss = missed_cycles * deprecation_rate
```

With default settings (90-day interval, 0.05 rate):
- 90 days overdue: -0.05
- 180 days overdue: -0.10
- 270 days overdue: -0.15

This ensures abandoned knowledge doesn't persist indefinitely.
