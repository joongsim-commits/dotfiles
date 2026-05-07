---
name: superpowers-executing-plans
description: >
  Use when you have a written implementation plan to execute inline (without sub-agents),
  with review checkpoints. Fallback when sub-agent-driven development is not preferred.
  Triggers on "execute inline", "run the plan myself", "no sub-agents", "inline execution".
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks, report when complete.

**Announce at start:** "I'm using the superpowers-executing-plans skill to implement this plan."

**Note:** The superpowers methodology works better with sub-agents. The quality of work is significantly higher with sub-agent support. If sub-agents are available, use `read_skill("superpowers-subagent-driven-development")` instead of this skill.

## Before Starting

**MANDATORY:** Before executing any tasks, ensure you are on an isolated branch:
- Load `read_skill("superpowers-using-git-worktrees")` and follow it
- Only proceed once you have a feature branch with a verified clean baseline

## The Process

### Step 1: Load and Review Plan

1. Read plan file
2. Review critically — identify any questions or concerns about the plan
3. If concerns: Raise them with the user before starting
4. If no concerns: Create `todo_write` checklist and proceed

### Step 2: Execute Tasks

For each task:
1. Mark as in_progress via `todo_write`
2. Follow TDD discipline — if the plan specifies tests, write the failing test first, verify it fails, then implement. Load `read_skill("superpowers-test-driven-development")` if unsure.
3. Follow each step exactly (plan has bite-sized steps)
4. Run verifications as specified via `exec`
5. Commit after each task passes verification
6. Mark as completed

### Step 3: Complete Development

After all tasks complete and verified:
- **MANDATORY:** Load `read_skill("superpowers-verification-before-completion")` — verify all tests pass with evidence before claiming completion
- Load `read_skill("superpowers-finishing-a-development-branch")` to present completion options

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## Remember

- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- Load referenced skills when plan says to
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent

## Integration

**Required workflow skills:**
- `read_skill("superpowers-using-git-worktrees")` — Ensures isolated workspace
- `read_skill("superpowers-writing-plans")` — Creates the plan this skill executes
- `read_skill("superpowers-finishing-a-development-branch")` — Complete development after all tasks
