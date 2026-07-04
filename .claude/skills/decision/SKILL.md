---
name: decision
description: |
  Log an architectural decision record (ADR) to docs/decisions.md.
  Use when making a significant technical choice: libraries, patterns, data models, infra.
  Also use when revisiting or superseding a past decision.
argument-hint: [short decision title]
---

# Log a Decision

## Step 1: Gather context

If $ARGUMENTS is empty, ask: "What decision are you recording?"

Ask the user for:
1. **Context** — What situation or problem forced this decision?
2. **Options considered** — What alternatives did you evaluate?
3. **Decision** — What did you choose?
4. **Consequences** — What are the trade-offs? Any risks?

## Step 2: Determine ADR number

Read `docs/decisions.md` and find the highest existing ADR number.
The new ADR number = highest + 1.

## Step 3: Write the ADR

Prepend the new ADR to `docs/decisions.md` (newest first) in this format:

```markdown
## ADR-NNN: [Title]

**Date:** YYYY-MM-DD
**Status:** Accepted

**Context:**
[Context text]

**Options Considered:**
- [Option A]: [brief pros/cons]
- [Option B]: [brief pros/cons]

**Decision:**
[Decision text]

**Consequences:**
- ✅ [Benefit]
- ⚠️ [Trade-off or risk]

---
```

Also update the summary table in `docs/architecture.md` under "Key Design Decisions" if the decision belongs there.

## Step 4: Confirm

Say: "ADR-NNN logged. You may want to reference this in the relevant spec or CLAUDE.md."
