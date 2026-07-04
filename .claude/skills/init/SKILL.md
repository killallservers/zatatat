---
name: init
description: |
  Project initialisation: interview the user and fill in all [TODO] sections
  across docs/ in one pass. Run once after installing Ground Zero.
  Do NOT write code during this skill.
disable-model-invocation: true
---

# Project Init

You just ran `install.sh`. The docs have `[TODO]` placeholders. Your job is to
fill them all in through a short interview — then write the files.

## Phase 1: Read first

Before asking anything:
1. Scan every file in `docs/` and list every `[TODO]` placeholder you find
2. Note which files they're in

## Phase 2: Interview

Ask these questions conversationally, one or two at a time. Don't present them as a form.

**Project identity**
- What's the project called?
- What does it do — one sentence?
- What problem does it solve?
- GitHub repo (org/repo)?

**Stack** — for each layer, ask what they've chosen or whether to use the default:
- Language (default: TypeScript 7)
- Runtime (default: Bun)
- Framework (default: Hono)
- Database (default: Postgres via Drizzle + bun-sql)
- Auth (default: Better Auth)
- Infra (default: Hetzner VPS + Pulumi + Caddy)
- Formatting (default: Biome)

If they say "default" or "same as the template", accept it and move on.

**Architecture**
- How does a request flow through the system end-to-end? (Even one sentence.)
- Any hard constraints the AI assistant must never violate?

**Domain language**
- Are there any project-specific terms that have a precise meaning?

Stop when you have enough to fill every `[TODO]` you found in Phase 1.

## Phase 3: Fill in the docs

Write the completed versions of every file that had `[TODO]` placeholders.
Use the answers from the interview. Do not leave any `[TODO]` unfilled.

Files to update at minimum:
- `docs/llm.md` — project overview, stack table, repo structure hint, conventions, constraints
- `docs/architecture.md` — system overview, component map, key decisions
- `docs/constraints.md` — never-do and always-do lists
- `docs/context.md` — domain language with real terms
- `docs/testing.md` — strategy and what must always be tested
- `docs/deployment.md` — platform, environments, env vars

Update the `*Last updated*` date in each file to today's date.

## Phase 4: Confirm

After writing all files, list what you filled in and ask:
"Anything to correct or expand before you start building?"

Make any requested changes, then say: "You're ready. Run `/spec-create <feature>` when you're ready to spec your first feature."
