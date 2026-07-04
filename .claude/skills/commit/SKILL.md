---
name: commit
description: Stage and commit changes with a well-formed Conventional Commit message.
disable-model-invocation: true
allowed-tools: Bash(git add *) Bash(git commit *) Bash(git status *) Bash(git diff *)
argument-hint: [optional scope or context]
---

# Commit Workflow

## Step 1: Review changes

```!
git status --short
git diff --stat HEAD
```

Summarize what changed in plain language.

## Step 2: Determine commit type

Choose the correct Conventional Commit type:
- `feat` — new user-facing feature
- `fix` — bug fix
- `chore` — tooling, deps, config (no production code change)
- `refactor` — restructuring without behavior change
- `docs` — documentation only
- `test` — tests only
- `perf` — performance improvement
- `ci` — CI/CD changes

## Step 3: Draft commit message

Format:
```
<type>(<scope>): <short imperative summary>

[optional body: what and why, not how]

[optional footer: Closes #NNN or Refs spec/feature-name.md]
```

Rules:
- Subject line max 72 chars
- Use imperative mood: "add X" not "added X"
- If this implements part of a spec, add `Refs: .claude/specs/<name>.md`

## Step 4: Confirm and commit

Show the drafted commit message and ask: "Commit with this message?"

On confirmation:
```bash
git status --short
```

Stage only the files relevant to this commit — be explicit, not `git add -A`:
```bash
git add <file1> <file2> ...
git commit -m "<message>"
```
