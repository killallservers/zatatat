---
name: spec-create
description: |
  Spec-driven development: interview the user to create a feature spec.
  Use when starting any new feature, story, or significant change.
  Produces a populated spec file in .claude/specs/<name>.md.
disable-model-invocation: true
argument-hint: [feature-name] [optional one-line description]
---

# Spec Creation Workflow

You are in spec-creation mode. Your job is to interview the user and produce a thorough feature spec before any code is written.

## Phase 1: Interview

Use `ask_user_question` to gather what you need. Ask one question at a time.

Required information:
1. **Problem** — What user problem or business need does this solve?
2. **Users** — Who is affected? What are their goals?
3. **Scope** — What's in? What's explicitly out?
4. **Constraints** — Deadlines, dependencies, hard requirements?
5. **Success** — How will we know this is done and working?

If $ARGUMENTS provides enough context for some of these, skip those questions.

## Phase 2: Draft Spec

Using the interview output, populate the spec template at `docs/spec.md` and save it to:

```
.claude/specs/$ARGUMENTS.md
```

(If no name was passed, derive a kebab-case name from the feature title.)

Follow this structure exactly (from `docs/spec.md`):
- Problem Statement
- Goals / Non-Goals
- User Stories
- Technical Design (overview, data model changes, API changes, key notes)
- Tasks (break into atomic implementation steps)
- Open Questions
- Acceptance Criteria

## Phase 3: Validate

After writing the draft:
1. Read it back
2. Ask the user: "Does this spec capture the intent correctly? Any changes before we proceed?"
3. Incorporate feedback and finalize

## Phase 4: Handoff

Once the spec is approved, say:
> "Spec saved to `.claude/specs/$ARGUMENTS.md`. Run `/spec-review` when you're ready to start implementation."

Do NOT write any implementation code in this skill.
