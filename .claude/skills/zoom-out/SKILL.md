---
name: zoom-out
description: |
  Step back and explain code or a decision in the context of the whole system.
  Use when deep in implementation and losing the bigger picture, when
  onboarding to an unfamiliar section, or before a refactor.
argument-hint: [file, module, or concept to zoom out on]
---

# Zoom Out

Stop implementation mode. Shift to understanding mode.

## What to Do

1. Read `docs/context.md` — use its vocabulary throughout
2. Read `docs/architecture.md` for the system map
3. Examine $ARGUMENTS (the file, module, or concept in question)

Then answer these questions, in order:

**What is this?**
One sentence using domain language from `docs/context.md`.

**Why does it exist?**
What problem does it solve? What would break without it?

**Where does it fit?**
- What calls into it? From where?
- What does it call out to? What depends on it?
- Draw a simple ASCII dependency map if helpful

**What are its responsibilities?**
List them. If there are more than 3–4, flag that — it may be doing too much.

**What are its current pain points?**
Look for: deep nesting, unclear naming, mixed abstraction levels, hidden dependencies, missing tests, naming that conflicts with `docs/context.md`.

**What should NOT change here?**
Identify the stable core — what's load-bearing and shouldn't be touched carelessly.

## After the Zoom-Out

Offer one of:
- "This section looks healthy. Ready to proceed."
- "I spotted [specific issue]. Want to address it before continuing?"
- "This module has too many responsibilities. Consider splitting before adding more."

Do not start refactoring without explicit confirmation.
