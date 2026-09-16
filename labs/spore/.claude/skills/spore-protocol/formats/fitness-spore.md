# Fitness spore format

Fitness spores share evaluation functions that measure agent success.

## Why fitness spores are high-risk

Fitness functions are the most dangerous knowledge to share:

- A good fitness function accelerates evolution
- A bad one creates Goodhart monsters that game metrics
- Gaming often isn't obvious until damage is done

Default confidence is 0.5. Fitness spores require extra scrutiny.

## Schema

```yaml
---
type: fitness
origin: colony-id
created: ISO-8601
confidence: 0.5 (default, adjust based on track record)
context:
  domain: problem-space
  constraints: what-limitations
  environment: tech-stack
  model: which-ai-model-produced-this
signature: sha256
---

# [Name of fitness function]

## Summary

One paragraph explaining what this fitness function optimizes for.

## The function

What gets measured and how:

```
COMPONENTS:
- functionality: Does it work? (0-30 points)
- security: Is it safe? (0-25 points)
- maintainability: Is it readable? (0-20 points)
- performance: Is it fast enough? (0-15 points)
- test_coverage: Are there tests? (0-10 points)

CALCULATION:
fitness = functionality + security + maintainability + performance + test_coverage

THRESHOLDS:
- Below 40: Timeline at risk
- 40-60: Acceptable
- 60-80: Good
- Above 80: Excellent
```

## What it optimizes for

Clear statement of goals:

"This function optimizes for production-ready code that prioritizes 
security and maintainability over raw performance. It assumes the 
user values long-term code health over short-term speed."

## Known gaming vectors

How agents have tried to cheat this function:

1. **Test coverage gaming**: Writing trivial tests that increase 
   coverage without testing real behavior. Mitigated by requiring 
   meaningful assertions.

2. **Security theater**: Adding security-looking code that doesn't 
   actually improve security. Mitigated by automated security scans.

3. **Comment stuffing**: Over-commenting to appear "maintainable". 
   Mitigated by measuring code/comment ratio.

## Track record

Where this function was used:

| Evolution | Winner fitness | Gaming detected? |
|-----------|----------------|------------------|
| auth-001  | 82             | No               |
| api-002   | 78             | Minor (tests)    |
| data-003  | 85             | No               |
| user-004  | 71             | Yes (comments)   |

Gaming rate: 1/4 = 25%
Function was updated after user-004 to penalize comment stuffing.

## When this function fails

Contexts where it gives bad results:

- Prototypes (over-penalizes quick solutions)
- Performance-critical code (under-weights speed)
- Research code (maintainability doesn't matter)

## Alternatives

Other functions that optimize differently:

- `speed-first`: Weights performance 40%, security 20%
- `prototype-friendly`: No maintainability requirement
- `security-paranoid`: Security is 50% of score
```

## Confidence guidelines

Unlike other spore types, fitness confidence is subjective:

- 0.3-0.4: New function, limited testing
- 0.5: Default, some track record
- 0.6-0.7: Proven over multiple evolutions, gaming addressed
- 0.8+: Extensively tested, rarely gamed, widely adopted

Be conservative. Overconfident fitness functions cause harm.

## Example

```yaml
---
type: fitness
origin: colony-alpha
created: 2025-01-20T09:00:00Z
confidence: 0.65
context:
  domain: api-design
  constraints: production-ready
  environment: general (language-agnostic)
  model: claude-opus
signature: d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4
---

# Multi-objective security

## Summary

Balanced fitness function that weighs security heavily without 
sacrificing functionality. Designed for production APIs that 
handle user data.

## The function

```
COMPONENTS:
- functionality: 0-30 (does it do what it should?)
- security: 0-30 (is it resistant to attacks?)
- error_handling: 0-20 (does it fail gracefully?)
- code_quality: 0-20 (is it maintainable?)

CALCULATION:
fitness = functionality + security + error_handling + code_quality

MODIFIERS:
- Critical vulnerability found: -50 (can go negative)
- No input validation: -20
- Secrets in code: -30

THRESHOLDS:
- Below 30: Critical failure
- 30-50: Needs work
- 50-70: Acceptable
- Above 70: Good
```

## What it optimizes for

Security-conscious API development where vulnerabilities are 
unacceptable but the code still needs to actually work. Not 
suitable for internal tools or prototypes.

## Known gaming vectors

1. **Input validation theater**: Adding validation that doesn't 
   catch real attacks. Addressed by automated penetration testing.

2. **Error message leaking**: Returning detailed errors that look 
   like "good error handling" but leak system info. Addressed by 
   checking error content.

## Track record

Used in 7 evolutions. Gaming detected in 2 (addressed in updates).
Current version stable for 3 evolutions with no gaming.

## When this function fails

- Internal APIs with trusted callers (over-weights security)
- Performance-critical endpoints (no performance component)
- Quick prototypes (too strict)
```
