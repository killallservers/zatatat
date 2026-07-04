---
name: diagnose
description: |
  Disciplined diagnosis loop for hard bugs, unexpected behaviour, or
  performance regressions. Use when you're stuck or when a fix attempt
  failed. Do NOT guess — follow the loop.
argument-hint: [description of the bug or symptom]
---

# Diagnosis Loop

Do not guess. Do not apply a fix until the root cause is confirmed.
Every step must produce evidence before moving to the next.

## Step 1: Reproduce

Goal: a reliable, minimal reproduction.

- Confirm the symptom: what exactly happens vs. what should happen?
- Find the smallest input / state / sequence that triggers it
- Confirm you can reproduce it consistently before continuing
- If you cannot reproduce it → stop and ask the user for more context

## Step 2: Minimise

Goal: remove everything that isn't the bug.

- Strip out unrelated code paths, data, configuration
- Confirm the symptom still occurs in the minimised form
- The smaller the reproduction, the faster everything else goes

## Step 3: Hypothesise

Goal: one falsifiable hypothesis about the root cause.

- State it explicitly: "I believe the bug is caused by X because Y"
- Rank by likelihood if you have multiple candidates — work top-down
- Do not form more than one hypothesis at a time

## Step 4: Instrument

Goal: evidence that confirms or refutes the hypothesis.

- Add targeted logging, assertions, or a focused test — whatever gives signal fastest
- Run and observe
- If the hypothesis is **confirmed** → proceed to fix
- If **refuted** → return to Step 3 with a new hypothesis
- Do not add speculative fixes as a form of instrumentation

## Step 5: Fix

Goal: the minimal change that eliminates the root cause.

- Fix the cause, not the symptom
- Do not add defensive code around the bug — remove the bug
- If the fix is larger than expected, stop and check whether the root cause diagnosis was correct

## Step 6: Regression Test

Goal: the bug cannot silently return.

- Write a test that would have caught this bug originally
- Run the full suite and confirm it passes
- If no test is possible, document why in a comment

---

After each step, briefly summarise what was found before moving on.
If at any point the bug is more complex than it appeared, surface that to the user rather than silently expanding scope.
