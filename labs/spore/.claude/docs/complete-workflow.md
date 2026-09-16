# SPORE complete workflow example

This document shows how SPORE integrates with FLUX and METAMORPHOSIS
in a complete evolution cycle.

## Scenario

You're building authentication for a new API. Your colony has been
running for a few weeks and has 3 peers.

## Step 1: Search network knowledge first

Before starting evolution, check what the network knows:

```
> /spore search "authentication api security"

Searching network knowledge...

FAILURES TO AVOID (3):
1. aggressive-auth-001 [0.73] - High aggression fails security audit
2. jwt-short-expiry [0.68] - 5-minute tokens cause bad UX
3. no-refresh-token [0.71] - Users forced to re-login constantly

SUCCESSFUL PATTERNS (2):
4. balanced-auth-validator [0.80] - Defensive approach, 8 generations
5. secure-token-handler [0.75] - Methodical token management

FITNESS FUNCTIONS (1):
6. multi-objective-security [0.65] - Balances security + usability

View details? [1-6/q] > 4

GENOME: balanced-auth-validator
─────────────────────────────────
Traits:
  analytical: 0.70
  defensive: 0.65
  methodical: 0.75
  creative: 0.35
  aggressive: 0.20

Skills:
  api-design, testing, security

Heritage prompt:
  "Defense in depth. Validate early, fail gracefully. Every external
   input is a potential attack until proven otherwise."

Survived: 8 generations
Peak fitness: 87

Use as starting point? [Y/n] > y

Added to available genomes for this evolution.
```

## Step 2: Start evolution with network knowledge

```
> /explore "Build JWT authentication with refresh tokens"

SPORE INTEGRATION ACTIVE
────────────────────────
Known-bad patterns loaded: 3
  - Will avoid aggressive > 0.7 with defensive < 0.3
  - Will avoid jwt expiry < 300 seconds
  - Will include refresh token handling

Starting genome available: balanced-auth-validator

Fitness function suggested: multi-objective-security

FORK INITIATED
══════════════════════════════════════════════════════════

Timeline-α: "Standard JWT with refresh" 
  Starting from: balanced-auth-validator genome
  Assumption: Follow proven pattern
  
Timeline-β: "Enhanced security variant"
  Starting from: fresh genes (analytical + defensive)
  Assumption: We can improve on network pattern
  
Timeline-γ: "Performance-focused auth"
  Starting from: fresh genes (methodical + experimental)
  Assumption: Speed matters more than network suggests
  ⚠️ WARNING: experimental trait flagged by known-bad patterns

All timelines exploring in parallel...
══════════════════════════════════════════════════════════
```

## Step 3: Evolution with network-informed decisions

```
> /evolve

Generation 2 complete.

Timeline-α: fitness 68 → 72
  Using balanced-auth-validator heritage
  Progress: Steady improvement, following proven patterns

Timeline-β: fitness 62 → 71  
  Developing own approach
  Progress: Catching up to network-derived baseline

Timeline-γ: fitness 58 → 45 ⚠️
  Triggered known-bad pattern: experimental without methodical balance
  Progress: DECLINING - matches network warning

RECOMMENDATION: Consider terminating Timeline-γ
Network data shows this pattern fails 73% of the time.

[T]erminate γ / [C]ontinue all / [D]etails
> t

Timeline-γ terminated.
Autopsy saved to: .claude/flux/graveyard/timeline-gamma-auth-001.md

This confirms network pattern. Update confidence? [Y/n] > y
Updated aggressive-auth-001 confidence: 0.73 → 0.76 (local confirmation)
```

## Step 4: Evolution completes

```
> /evolve
> /evolve
> /evolve

Generation 5 complete.

Timeline-α: fitness 72 → 78 → 82 → 85
Timeline-β: fitness 71 → 74 → 79 → 81

Both timelines healthy. Ready for selection.

> /select

Comparing timelines:

Timeline-α (from network genome):
  Final fitness: 85
  Generations: 5
  Approach: Followed balanced-auth-validator pattern
  Strengths: Proven, stable, well-tested
  Weaknesses: Less innovative

Timeline-β (fresh approach):
  Final fitness: 81
  Generations: 5
  Approach: Developed independently
  Strengths: Novel error handling
  Weaknesses: Less battle-tested

Select winner: [A/B] > a

Timeline-α selected as winner!
Saved to: .claude/flux/winners/auth-jwt-refresh-001.md

METAMORPHOSIS GOVERNANCE
────────────────────────
Submitting to Council for review...

Council review:
  Claude Opus: APPROVE (follows established patterns)
  GPT-5: APPROVE (edge cases handled)
  Gemini Pro: APPROVE (security audit passed)
  
Human pool notified via Slack (major decision):
  @erik: APPROVE
  
RATIFIED by Council (4-0 with human confirmation)

Ledger entry #4522:
  Type: SOLUTION_APPROVAL
  Network knowledge used: balanced-auth-validator genome (colony-beta)
  Known-bad patterns avoided: 3 (from network)
  Attribution: Timeline-alpha gen-005

Implementation authorized.
```

## Step 5: Share learnings with network

```
> /spore announce --list

Publishable learnings from this evolution:

GRAVEYARD (ready to share):
  timeline-gamma-auth-001.md
    Pattern: experimental(0.8) + methodical(0.2) fails on auth
    Observations: 1 local + 11 from network = 12 total
    Confidence: Would update network from 0.73 to 0.76
    
    This CONFIRMS existing network knowledge.
    Share confirmation? [Y/n] > y

WINNERS (ready to share):
  auth-jwt-refresh-001.md
    Derived from: balanced-auth-validator (network genome)
    Improvements: Added retry logic, better error messages
    Generations: 5
    
    This EXTENDS existing network pattern.
    Share as new genome variant? [Y/n] > y

Packaging spores...

graveyard/timeline-gamma-auth-001.md
  Security check: PASS
  Context added: PASS
  Signature computed: PASS
  -> outbox/graveyard/timeline-gamma-auth-001.md

genome/auth-jwt-refresh-variant.md
  Security check: PASS
  Heritage prompt: PASS
  Signature computed: PASS
  -> outbox/genome/auth-jwt-refresh-variant.md

Ready to publish. Run git push? [Y/n] > y

git add .claude/spore/outbox/
git commit -m "Add spores: graveyard confirmation, genome variant"
git push

Published! Available to peers on their next /spore pull.
```

## Step 6: Network effects

Later, at colony-beta:

```
> /spore pull

Pulling from 3 peers...

colony-alpha: 2 new spores
  - graveyard/timeline-gamma-auth-001.md
  - genome/auth-jwt-refresh-variant.md

> /spore validate --all

[1/2] graveyard/timeline-gamma-auth-001.md
  From: colony-alpha (reliability: 0.87)
  Type: Confirmation of existing pattern
  
  This confirms pattern we already have.
  Our confidence: 0.73
  With confirmation: 0.76
  
  VERDICT: INTEGRATE (update confidence)

[2/2] genome/auth-jwt-refresh-variant.md
  From: colony-alpha (reliability: 0.87)
  Type: Variant of balanced-auth-validator
  
  Differences from our version:
  + Added retry logic on token refresh
  + Better error messages
  - Slightly more complex
  
  VERDICT: INTEGRATE (add as variant option)

Integration complete.
Colony-beta now has improved auth patterns available.
```

## The compound effect

After 30 days of network operation:

```
> /spore status

NETWORK KNOWLEDGE ACCUMULATED
─────────────────────────────

This colony:
  Spores received: 127
  Spores integrated: 98 (77%)
  Spores contributed: 23
  
  Local evolutions: 12
  Informed by network: 10 (83%)
  Failures avoided: ~15 (estimated from known-bad hits)

Network health:
  Known peers: 5
  Average reliability: 0.81
  Pattern diversity: HEALTHY (no pattern > 45%)
  
Top contributors:
  1. colony-alpha: 34 integrated spores
  2. colony-beta: 28 integrated spores
  3. This colony: 23 contributed spores
  4. colony-gamma: 18 integrated spores
  5. colony-delta: 12 integrated spores

Knowledge by domain:
  authentication: 31 spores (well covered)
  api-design: 42 spores (well covered)
  databases: 19 spores (moderate)
  testing: 28 spores (well covered)
  frontend: 7 spores (sparse)
```

## Summary

The complete flow:

```
┌─────────────────────────────────────────────────────────────┐
│                        NETWORK                              │
│   colony-alpha ←→ colony-beta ←→ colony-gamma ←→ ...       │
└─────────────────────────┬───────────────────────────────────┘
                          │
          ┌───────────────┼───────────────┐
          │ /spore pull   │  /spore push  │
          ▼               │               ▲
    ┌──────────┐          │         ┌──────────┐
    │  inbox/  │          │         │  outbox/ │
    └────┬─────┘          │         └────┬─────┘
         │                │              │
         ▼                │              │
    ┌─────────┐           │         ┌─────────┐
    │VALIDATOR│           │         │PACKAGER │
    └────┬────┘           │         └────┬────┘
         │                │              │
         ▼                │              ▲
    ┌──────────────┐      │       ┌──────────────┐
    │  integrated/ │──────┼──────►│  graveyard/  │
    └──────┬───────┘      │       │  winners/    │
           │              │       └──────┬───────┘
           │              │              │
           │        ┌─────┴─────┐        │
           └───────►│   FLUX    │◄───────┘
                    │ evolution │
                    └─────┬─────┘
                          │
                          ▼
                    ┌───────────────┐
                    │METAMORPHOSIS  │
                    │  governance   │
                    └───────────────┘
```

Each evolution is informed by network knowledge.
Each completion contributes back to the network.
The collective learns faster than any colony alone.
