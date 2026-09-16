# Genome spore format

Genome spores capture successful gene combinations that survived evolution.

## Schema

```yaml
---
type: genome
origin: colony-id
created: ISO-8601
confidence: 0.0-1.0
context:
  domain: problem-space
  constraints: what-limitations
  environment: tech-stack
  model: which-ai-model-produced-this
signature: sha256
---

# [Descriptive name for this genome]

## Summary

One paragraph explaining what this genome does well and why it works.

## Gene combination

Traits (personality):
- analytical: 0.7
- defensive: 0.6
- methodical: 0.8
- creative: 0.3

Skills (domain knowledge):
- api-design
- testing
- security

## Heritage prompt

The condensed wisdom of why this genome works. Not code, but principles:

"This genome succeeds by prioritizing validation over speed. It treats 
every external input as potentially hostile and builds defensive layers 
before implementing features. The methodical trait ensures nothing is 
skipped, while moderate creativity allows for non-obvious solutions 
when standard approaches fail."

## Survival record

- Generations survived: 8
- Peak fitness: 87
- Fitness at selection: 82
- Challenges overcome:
  - Security audit (gen-003)
  - Performance test (gen-005)
  - Edge case stress test (gen-007)

## Fitness functions it succeeded against

1. `multi-objective-security` - Balanced security + functionality
2. `defensive-coverage` - Emphasized error handling
3. `user-approval` - Human rated outputs positively

## Known weaknesses

Where this genome struggles:

- Speed-critical tasks (methodical trait slows it down)
- Highly creative work (low creativity score)
- Rapidly changing requirements (defensive posture resists change)

## When to use

Good fit:
- Security-critical systems
- Production code that needs to be robust
- APIs that face external traffic

Poor fit:
- Prototypes and throwaway code
- Creative writing or design
- Time-pressured hackathon projects
```

## Confidence calculation

```
confidence = min(1.0, generations_survived / 10)
```

8 generations = 0.8 confidence
10+ generations = 1.0 confidence

## Model context

METAMORPHOSIS supports multi-model evolution where different timelines 
may use different AI models (Claude, GPT, Gemini, local models). The 
model that produced a genome can affect why it works:

- A Claude-produced genome may reflect stronger reasoning patterns
- A GPT-produced genome may handle edge cases differently
- A Gemini-produced genome may favor rapid iteration patterns

The `model` field in context helps receiving colonies understand 
whether a genome's success is model-dependent or transferable. If 
a genome consistently succeeds across multiple models, its confidence 
should be higher.

## Example

```yaml
---
type: genome
origin: colony-beta
created: 2025-01-25T14:20:00Z
confidence: 0.80
context:
  domain: api-design
  constraints: production-ready, high-traffic
  environment: Node.js, Express, PostgreSQL
  model: claude-sonnet
signature: c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3
---

# Defensive API handler

## Summary

A balanced genome optimized for building robust API endpoints that 
handle errors gracefully and resist malformed input. Trades some 
development speed for reliability.

## Gene combination

Traits:
- analytical: 0.7
- defensive: 0.65
- methodical: 0.75
- creative: 0.35
- aggressive: 0.2

Skills:
- api-design
- testing
- security
- postgres

## Heritage prompt

"Defense in depth. Validate early, fail gracefully, log everything. 
Every external input is a potential attack vector until proven 
otherwise. Build the happy path last, after all error paths work."

## Survival record

- Generations: 8
- Peak fitness: 87
- Final fitness: 82
- Key challenges:
  - Survived SQL injection test (gen-003)
  - Handled 10x traffic spike (gen-005)
  - Recovered from database failure (gen-007)

## Fitness functions passed

1. multi-objective-security (score: 84)
2. error-recovery-coverage (score: 89)
3. user-approval (score: 78)

## Known weaknesses

- 40% slower initial development than aggressive genomes
- Over-validates in trusted internal contexts
- Can be overly cautious on edge cases that don't matter

## When to use

Recommended for public APIs, payment processing, user data handling.
Not recommended for internal tools, prototypes, or time-critical MVPs.
```
