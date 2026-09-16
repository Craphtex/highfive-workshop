# Governance spore format

Governance spores share institutional patterns for organizing AI agent systems.

## Why governance spores are rare

Governance patterns are highly context-dependent:
- What works for one team may fail for another
- Cultural factors matter
- Scale affects which patterns work
- Risk tolerance varies

Default: `share_governance: false` in config.
Only share governance when explicitly valuable and requested.

## When to share governance

Good candidates:
- Pattern has been stable for 30+ days
- Multiple evolutions completed under this governance
- Clear rationale exists for design choices
- Trade-offs are well-documented

Poor candidates:
- New or experimental governance
- Patterns tied to specific team dynamics
- Patterns that assume specific tooling
- Anything without clear rationale

## Schema

```yaml
---
type: governance
origin: colony-id
created: ISO-8601
confidence: 0.0-1.0
context:
  domain: what kind of problems this governs
  scale: team-size or evolution-frequency this works for
  risk_tolerance: conservative | moderate | aggressive
  culture: relevant cultural factors
  model: which AI model(s) this governance was designed around
signature: sha256
---

# [Name of governance pattern]

## Summary

One paragraph explaining what this governance pattern does.

## The pattern

Detailed description of how the governance works:

### Structure
Who/what are the governing entities?

### Powers
What can each entity do?

### Checks
How are powers balanced?

### Process
How do decisions flow?

### Voting model
How are decisions reached? Options include:
- Consensus (all must agree)
- Weighted majority (different voices have different weight)
- AI recommendation + human veto (Council model from METAMORPHOSIS)
- Timeout with default (auto-approve if no response within window)

### Timeouts
What happens when decisions stall?
- Review window duration
- Default action on timeout
- Escalation trigger

### Escalation
What happens when normal process fails?
- Who gets escalated to
- Under what conditions
- What powers the escalation body has

### Meta-governance
Who can change these rules, and how?
- What threshold is needed to modify governance
- How are changes proposed and ratified
- What protections exist against governance capture

## Rationale

Why this pattern was chosen over alternatives:

### Problem it solves
What failure mode or risk does this address?

### Alternatives considered
What other approaches were evaluated?

### Why this won
What made this pattern better for your context?

## Requirements

What your colony needs for this to work:
- Minimum agents
- Required capabilities
- Cultural prerequisites

## Trade-offs

### Advantages
- [List benefits]

### Disadvantages
- [List costs]

### When this fails
- [Contexts where this pattern breaks down]

## Track record

How long has this been running?
What evolutions completed under this governance?
Any amendments or changes made?

## Implementation notes

Specific details for setting this up:
- Required files
- Configuration changes
- Integration points
```

## Confidence guidelines

Governance confidence is conservative:

- 0.3-0.4: Pattern is new, limited testing
- 0.5-0.6: Pattern stable for 30+ days, several evolutions
- 0.7-0.8: Pattern stable for 90+ days, proven across contexts
- 0.9+: Very rare, requires extensive cross-colony validation

## Example

```yaml
---
type: governance
origin: colony-beta
created: 2025-01-10T09:00:00Z
confidence: 0.65
context:
  domain: code-generation, api-design
  scale: 2-5 evolutions per week
  risk_tolerance: moderate
  culture: values safety over speed, prefers consensus
signature: e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5
---

# Rotating critic with veto power

## Summary

A governance pattern where the Critic role rotates between different 
evaluation perspectives, and any Critic can veto an evolution's 
winner if it fails their specific criteria.

## The pattern

### Structure

Three Critic perspectives that rotate:
1. **Security Critic**: Focuses on vulnerabilities, attack vectors
2. **Quality Critic**: Focuses on maintainability, testing, clarity
3. **Fitness Critic**: Focuses on whether solution actually solves problem

One active at a time. Rotates each evolution.

### Powers

Each Critic can:
- Review any timeline before selection
- Request additional generations
- VETO a winner (blocks selection, requires revision)
- Approve (required for selection to proceed)

Critic cannot:
- Modify code directly
- Override another Critic's past decisions
- Veto more than once per evolution

### Checks

- Veto must include specific, actionable feedback
- Vetoed evolution gets 2 more generations to address concerns
- Second veto on same evolution triggers Senate review
- Senate can override Critic with 2/3 majority

### Process

```
Evolution completes
       |
       v
Current Critic reviews winner
       |
       +---> APPROVE ---> Selection proceeds
       |
       +---> VETO ---> 2 more generations
                |
                v
           Critic re-reviews
                |
                +---> APPROVE ---> Selection proceeds
                |
                +---> VETO ---> Senate review
                           |
                           v
                    Senate votes
                           |
                    +---> Override (2/3) ---> Selection proceeds
                    |
                    +---> Uphold ---> Evolution fails, restart
```

## Rationale

### Problem it solves

Single-perspective evaluation misses important failure modes.
Security issues slip through quality-focused review.
Quality issues slip through fitness-focused review.

### Alternatives considered

1. **All Critics review every evolution**: Too slow, bottleneck
2. **Random Critic per evolution**: No guaranteed coverage
3. **User chooses Critic**: Bias toward comfortable perspectives

### Why this won

Rotation ensures all perspectives get applied over time.
Veto power ensures no critical issue gets ignored.
Senate override prevents single Critic from blocking everything.

## Requirements

- At least 3 distinct Critic prompts
- Senate agent (or equivalent oversight body)
- Tracking of which Critic reviewed which evolution

## Trade-offs

### Advantages
- Comprehensive coverage over time
- Clear accountability per evolution
- Prevents gaming any single evaluation style

### Disadvantages
- Some evolutions face harder Critics than others
- Veto power can slow velocity
- Requires maintaining multiple Critic variants

### When this fails
- Very fast iteration needed (veto too slow)
- Homogeneous problems (rotation adds no value)
- Solo developer (can't maintain separation of concerns)

## Track record

- In use: 45 days
- Evolutions governed: 23
- Vetoes used: 4 (17%)
- Vetoes overridden by Senate: 1
- Pattern changes: 1 (added Senate override after Critic deadlock)

## Implementation notes

Files needed:
- `.claude/agents/metamorphosis/critic-security.md`
- `.claude/agents/metamorphosis/critic-quality.md`
- `.claude/agents/metamorphosis/critic-fitness.md`
- `.claude/agents/metamorphosis/senate.md`
- `.claude/metamorphosis/critic-rotation.md` (tracks current Critic)

Configuration:
```yaml
governance:
  critic_rotation: [security, quality, fitness]
  current_critic: security
  veto_limit_per_evolution: 1
  senate_override_threshold: 0.67
```
```

## Receiving governance spores

Governance spores always go to quarantine. If the colony has a 
Council (multi-model AI + human pool), governance integration 
requires Council-level approval, not just Senate review:

```
/spore validate governance/rotating-critic.md

Type: governance
Auto-quarantine: YES (governance requires explicit approval)

Governance spores cannot be auto-integrated.
Run /spore quarantine to review.
```

When reviewing:

```
/spore quarantine 3

GOVERNANCE REVIEW: rotating-critic.md
═════════════════════════════════════

This is a governance pattern. Extra scrutiny required.

COMPATIBILITY CHECK:
  Your current governance: [basic single-critic]
  Proposed governance: [rotating critic with veto]
  
  Changes required:
  - Add 2 new Critic agents
  - Add Senate override capability
  - Track rotation state
  
  Estimated setup: 30-60 minutes

CONTEXT MATCH:
  Their scale: 2-5 evolutions/week
  Your scale: 3-4 evolutions/week ✓ MATCH
  
  Their risk tolerance: moderate
  Your risk tolerance: moderate ✓ MATCH

RECOMMENDATION:
  Pattern appears compatible with your context.
  Consider piloting for 2-3 evolutions before full adoption.

ACTIONS:
  [I] Integrate (adopt this governance)
  [P] Pilot (try for limited evolutions)
  [R] Reject (not suitable)
  [S] Save for later (keep in quarantine indefinitely)
```
