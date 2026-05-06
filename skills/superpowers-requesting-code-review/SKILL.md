---
name: superpowers-requesting-code-review
description: >
  Use when completing tasks, implementing major features, or before merging to verify
  work meets requirements. Dispatches a code reviewer sub-agent. Triggers on "review
  this code", "code review", "check my work", "before merging", "review before PR".
---

# Requesting Code Review

Dispatch a code reviewer sub-agent to catch issues before they cascade. The reviewer gets precisely crafted context for evaluation — never your session's history. This keeps the reviewer focused on the work product, not your thought process.

**Core principle:** Review early, review often.

## When to Request Review

**Mandatory:**
- After each task in subagent-driven development
- After completing major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request

**1. Get git SHAs:**

```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Dispatch code reviewer sub-agent:**

Use `spawn_subagent` with the template from `references/code-reviewer-prompt.md`.

**Placeholders:**
- `{DESCRIPTION}` — Brief summary of what you built
- `{PLAN_OR_REQUIREMENTS}` — What it should do
- `{BASE_SHA}` — Starting commit
- `{HEAD_SHA}` — Ending commit

```
execution_id = spawn_subagent(task="<filled template from references/code-reviewer-prompt.md>")

wait_for(interests=[
  {"sub_agent": {"execution_id": execution_id}},
  {"timer": {"duration": "10m"}}
])

delete_subagent(execution_id)
```

**3. Act on feedback:**
- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back if reviewer is wrong (with reasoning)

## Integration with Workflows

**Subagent-Driven Development:**
- Review after EACH task
- Catch issues before they compound
- Fix before moving to next task

**Executing Plans:**
- Review after each task or at natural checkpoints
- Get feedback, apply, continue

**Ad-Hoc Development:**
- Review before merge
- Review when stuck
