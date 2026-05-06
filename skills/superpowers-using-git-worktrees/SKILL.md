---
name: superpowers-using-git-worktrees
description: >
  Use when starting feature work that needs isolation from the current workspace, or
  before executing implementation plans. Ensures work happens on an isolated branch
  with a clean baseline. Triggers on "start feature", "new branch", "isolate work",
  "before implementing", "set up workspace".
---

# Branch Isolation for Feature Work

## Overview

Ensure work happens on an isolated branch with a verified clean baseline before implementation begins.

**Core principle:** Never start feature work on the default branch. Create isolation, verify the baseline, then implement.

**Announce at start:** "I'm using the superpowers-using-git-worktrees skill to set up an isolated workspace."

## Step 0: Detect Current State

**Before creating anything, check where you are:**

```bash
BRANCH=$(git branch --show-current)
DEFAULT=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
```

**If already on a feature branch (not main/master/develop):**
Skip to Step 2 (Project Setup). Report: "Already on feature branch `<branch>`. Skipping branch creation."

**If on the default branch:**
Proceed to Step 1.

## Step 1: Create Feature Branch

**Ask for consent if the user hasn't already indicated a preference:**

> "Would you like me to create a feature branch for this work? It protects your current branch from changes."

Honor any existing declared preference without asking. If the user declines, work in place and skip to Step 2.

**Create the branch:**

```bash
git checkout -b <feature-branch-name>
```

Use a descriptive branch name based on the feature being implemented (e.g., `feat/add-user-auth`, `fix/login-timeout`).

## Step 2: Project Setup

Auto-detect and run appropriate setup:

```bash
# Node.js
if [ -f package.json ]; then npm install; fi

# Rust
if [ -f Cargo.toml ]; then cargo build; fi

# Python
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi

# Go
if [ -f go.mod ]; then go mod download; fi
```

## Step 3: Verify Clean Baseline

Run tests to ensure workspace starts clean:

```bash
# Use project-appropriate command
npm test / cargo test / pytest / go test ./...
```

**If tests fail:** Report failures, ask whether to proceed or investigate.
**If tests pass:** Report ready.

### Report

```
Branch ready: <branch-name>
Tests passing (<N> tests, 0 failures)
Ready to implement
```

## Quick Reference

| Situation | Action |
|-----------|--------|
| Already on feature branch | Skip creation (Step 0) |
| On default branch | Create feature branch (Step 1) |
| User declines branch | Work in place |
| Tests fail during baseline | Report failures + ask |
| No package.json/Cargo.toml | Skip dependency install |

## Common Mistakes

### Skipping baseline verification
- **Problem:** Can't distinguish new bugs from pre-existing issues
- **Fix:** Always run tests before starting work

### Starting on main/master
- **Problem:** Risk of polluting the default branch with incomplete work
- **Fix:** Always create a feature branch first

### Proceeding with failing tests
- **Problem:** New failures get mixed with pre-existing ones
- **Fix:** Report failures, get explicit permission to proceed

## Red Flags

**Never:**
- Start feature work on main/master without explicit user consent
- Skip baseline test verification
- Proceed with failing tests without asking

**Always:**
- Check current branch state first
- Create feature branch for isolation
- Auto-detect and run project setup
- Verify clean test baseline
