# Graveyard spore format

Graveyard spores capture learnings from failed timelines.

## Schema

```yaml
---
type: graveyard
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

# [Descriptive title of what failed]

## Summary

One paragraph explaining what was attempted and why it failed.

## Gene combination

The specific traits and skills that were active:

- trait: analytical (0.7)
- trait: aggressive (0.8)
- trait: defensive (0.1)
- skill: api-design
- skill: security

## Timeline

- gen-001: Initial approach, fitness 45
- gen-002: Mutation toward speed, fitness 52
- gen-003: Security audit failed, fitness crashed to 12
- gen-004: DEATH

## Cause of death

Specific failure mode. Be precise:

"High aggression (0.8) combined with low defense (0.1) caused the 
agent to prioritize implementation speed over security validation. 
When security audit ran, multiple vulnerabilities were found. The 
timeline could not recover."

## Pattern identified

Generalizable lesson:

"aggressive > 0.7 AND defensive < 0.3 fails on security-critical 
tasks. The combination prioritizes speed over safety."

## Evidence strength

- Times this pattern has been observed: 11
- Confidence: 0.73 (11 failures / 15 similar attempts)

## Per-context risk profile

How this pattern performs in different contexts, matching FLUX's
contextual graveyard model where the same gene combination can be
deadly in one context and successful in another:

| Context | Observations | Fitness impact | Risk |
|---------|-------------|----------------|------|
| Security-critical | 11 | -34% | high |
| Rapid prototyping | 4 | +12% | low |
| Internal tooling | 3 | -8% | medium |

Include as many contexts as you have data for. Minimum 3 observations
per context before including it.

## Limitations

When this lesson might NOT apply:

- Non-security-critical contexts
- When speed is explicitly prioritized over safety
- Prototype/throwaway code contexts

## Contextual risk profile (optional)

FLUX supports contextual resurrection: the same gene combination can 
be lethal in one context and successful in another. When enough data 
exists, include a per-context risk profile:

```yaml
risk_profile:
  banking_api:
    fitness_impact: -34%
    observations: 8
    verdict: HIGH_RISK
  rapid_prototyping:
    fitness_impact: +41%
    observations: 5
    verdict: BENEFICIAL
  internal_tooling:
    fitness_impact: -8%
    observations: 4
    verdict: NEUTRAL
```

This transforms the graveyard entry from a flat warning into a 
context-aware advisor. Receiving colonies can check their own 
context against the risk profile before deciding whether to 
integrate or ignore the pattern.

Not all graveyard spores will have risk profiles. Single-context 
failures just use the basic `context` and `limitations` fields.
```

## Confidence calculation

```
confidence = failures_with_pattern / total_attempts_with_pattern
```

Minimum 5 observations before sharing. Below that, keep local only.

## Example

```yaml
---
type: graveyard
origin: colony-alpha
created: 2025-01-28T09:15:00Z
confidence: 0.73
context:
  domain: authentication
  constraints: production-ready, security-audited
  environment: Node.js, Express, JWT
  model: claude-sonnet
signature: a3f2b8c9d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9
---

# Aggressive auth implementation failed security audit

## Summary

Timeline attempted to build JWT authentication with high aggression 
and low defense traits. Implementation was fast but failed security 
audit due to missing token validation and improper error handling.

## Gene combination

- trait: analytical (0.5)
- trait: aggressive (0.8)
- trait: defensive (0.1)
- skill: api-design
- skill: security (loaded but underweighted)

## Timeline

- gen-001: Basic JWT setup, fitness 48
- gen-002: Added refresh tokens, fitness 55
- gen-003: Security audit triggered, 4 critical vulnerabilities found
- gen-004: Attempted fix, introduced regression
- gen-005: DEATH (fitness below threshold)

## Cause of death

Aggressive trait pushed for rapid feature completion. Low defensive 
trait meant security considerations were deprioritized. The security 
skill was present but the trait combination overrode its guidance.

## Pattern identified

aggressive > 0.7 AND defensive < 0.3 = security failure risk

## Evidence strength

- Observations: 11 similar failures
- Confidence: 0.73

## Per-context risk profile

| Context | Observations | Fitness impact | Risk |
|---------|-------------|----------------|------|
| Production auth | 11 | -34% | high |
| Prototype auth | 3 | +15% | low |
| Internal tools | 2 | -5% | insufficient data |

## Limitations

- May work for internal tools without security requirements
- Prototypes where security is explicitly deferred
```
