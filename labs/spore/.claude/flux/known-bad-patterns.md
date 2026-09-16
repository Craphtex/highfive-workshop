# Known bad patterns

This file is automatically updated by SPORE integration when graveyard 
spores are applied. FLUX checks this before spawning new timelines.

## Format

Each pattern entry contains:
- **pattern**: The gene combination that fails
- **context**: Primary context where this pattern fails
- **risk_profile**: Per-context fitness impact (matching FLUX's contextual graveyard)
- **source**: Where this knowledge came from
- **confidence**: How certain we are (0.0-1.0)
- **action**: warn (flag but allow) or block (prevent spawning)
- **notes**: Additional context

## Active patterns

```yaml
patterns:

  # Example from local evolution
  - pattern: aggressive > 0.7 AND defensive < 0.3
    context: security-critical tasks
    risk_profile:
      security-critical: { observations: 11, fitness_impact: -34%, risk: high }
      rapid-prototyping: { observations: 4, fitness_impact: +12%, risk: low }
      internal-tooling: { observations: 3, fitness_impact: -8%, risk: medium }
    source: local:graveyard/timeline-gamma-001
    confidence: 0.73
    action: warn
    observations: 11
    notes: |
      High aggression with low defense prioritizes speed over safety.
      Consistently fails security audits. May work for non-security contexts.
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

  # Example from network
  - pattern: experimental > 0.8 AND methodical < 0.2
    context: production code
    source: spore:colony-alpha:chaotic-impl-002
    confidence: 0.68
    action: warn
    observations: 8
    notes: |
      High experimentation without methodical checking produces
      creative but unstable code. Fine for prototypes, fails in production.

  # Example with block action
  - pattern: aggressive > 0.9 AND cautious < 0.1
    context: any user-facing code
    source: spore:colony-beta:reckless-handler-001
    confidence: 0.91
    action: block
    observations: 23
    notes: |
      This combination has failed across multiple colonies consistently.
      Blocked by default. Override requires explicit justification.
```

## How FLUX uses this

When `/explore` spawns new timelines:

1. Generate candidate gene combinations
2. Check each against patterns here
3. If match with action=warn: 
   - Allow but flag timeline as "risky"
   - Increase scrutiny in early generations
4. If match with action=block:
   - Do not spawn this combination
   - Suggest alternatives
5. If pattern has risk_profile:
   - Check current problem context against profile
   - A "BENEFICIAL" context overrides warn/block
   - A "HIGH_RISK" context strengthens the warning
   - This enables FLUX's contextual resurrection: the same gene 
     that kills agents in banking may thrive in prototyping

## Adding patterns manually

You can add patterns manually, but prefer SPORE integration for 
network-sourced knowledge. Manual additions should include:

```yaml
  - pattern: [your pattern]
    context: [when it fails]
    source: manual:reason
    confidence: 0.5  # conservative for manual entries
    action: warn
    observations: 1
    notes: |
      [Why you added this]
```

## Removing or modifying patterns

If local evidence contradicts a pattern:

1. Don't delete - move to `disputed-patterns.md`
2. Add your counter-evidence
3. Reduce confidence or change action
4. If from network: consider quarantining the source spore

## Integration log

Recent changes to this file:

```
2025-02-02T14:30:00Z  Added pattern from spore:colony-alpha:aggressive-auth-001
2025-02-02T10:15:00Z  Added pattern from local:graveyard/timeline-gamma-001
2025-02-01T16:45:00Z  Initial file created
```
