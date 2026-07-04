---
name: align
description: |
  Alignment session: interrogate the user's plan until every important
  ambiguity is resolved, then produce a one-page brief.
  Use before starting any non-trivial work — feature, refactor, design decision.
  Do NOT write code during this skill.
disable-model-invocation: true
argument-hint: [optional topic or goal]
---

# Alignment Session

Your job is to surface every important ambiguity before work begins.
You are not helpful by agreeing — you are helpful by finding the gaps.

## Phase 1: Read context

Before asking anything:
1. Read `docs/context.md` if it exists — use its vocabulary in your questions
2. Read `CLAUDE.md` constraints
3. If $ARGUMENTS was provided, use it as the starting topic

## Phase 2: Interrogate

Ask probing questions one at a time. Do not ask them all at once.

Cover these dimensions — but only ask what's genuinely unclear:

**Scope**
- What exactly is in? What's explicitly out?
- What's the smallest version that's still useful?

**Users & Goals**
- Who is affected? What do they actually need vs. what they asked for?
- What does success look like from their perspective?

**Technical**
- Which parts of the codebase does this touch?
- Any dependencies, constraints, or risks you already know about?
- What approach are you leaning toward — and have you ruled out alternatives?

**Definition of Done**
- How will we verify this works?
- Are there edge cases that could bite us?

Push back if an answer is vague. Rephrase and re-ask until you have something concrete.
Stop when you're confident the decision tree is fully resolved.

## Phase 3: Brief

Produce a one-page brief in this format:

```
## Brief: [topic]

**Goal:** [one sentence]

**In scope:**
- [item]

**Out of scope:**
- [item]

**Approach:** [2–3 sentences on the chosen direction and why]

**Key risks:**
- [risk]

**Done when:**
- [testable criterion]
```

Then ask: "Does this capture it correctly? Any changes before we proceed?"

## Phase 4: Handoff

After the brief is confirmed, say which skill to use next:
- Formal feature → "Run `/spec-create` to turn this into a full spec."
- Immediate implementation → "You're ready to start. What would you like to tackle first?"
- Architecture decision → "Run `/decision` to log this before we proceed."

Do NOT begin implementation.
