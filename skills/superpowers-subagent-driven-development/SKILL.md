---
name: superpowers-subagent-driven-development
description: >
  Use when executing implementation plans with independent tasks in the current session.
  Dispatches a fresh sub-agent per task with two-stage review (spec compliance, then code
  quality). Triggers on "execute the plan", "start implementing", "run the plan",
  "subagent driven", "dispatch tasks".
---

# Subagent-Driven Development

Execute a plan by dispatching a fresh sub-agent per task, with two-stage review after each: spec compliance review first, then code quality review.

**Why sub-agents:** You delegate tasks to specialized agents with isolated context. By precisely crafting their instructions and context, you ensure they stay focused and succeed. They should never inherit your session's context or history — you construct exactly what they need. This also preserves your own context for coordination work.

**Core principle:** Fresh sub-agent per task + two-stage review (spec then quality) = high quality, fast iteration

**Continuous execution:** Do not pause to check in with the user between tasks. Execute all tasks from the plan without stopping. The only reasons to stop are: BLOCKED status you cannot resolve, ambiguity that genuinely prevents progress, or all tasks complete.

## When to Use

- Have an implementation plan with mostly independent tasks
- Want to stay in this session (no context switch)
- Want automated review between tasks

**vs. Executing Plans:** This skill uses sub-agents for isolation and review. `superpowers-executing-plans` executes inline with human checkpoints.

## Before Starting

**MANDATORY:** Before executing any tasks, ensure you are on an isolated branch:
- Load `read_skill("superpowers-using-git-worktrees")` and follow it
- Only proceed once you have a feature branch with a verified clean baseline

## The Process

1. Read plan, extract all tasks with full text, note context, create `todo_write` checklist
2. **Per task:**
   a. Dispatch implementer sub-agent (see `references/implementer-prompt.md`)
   b. If implementer asks questions → answer, provide context
   c. Implementer implements, tests, commits, self-reviews
   d. Dispatch spec reviewer sub-agent (see `references/spec-reviewer-prompt.md`)
   e. If spec issues found → implementer fixes, re-review
   f. Dispatch code quality reviewer sub-agent (see `references/code-quality-reviewer-prompt.md`)
   g. If quality issues found → implementer fixes, re-review
   h. Mark task complete in `todo_write`
3. After all tasks: dispatch final code reviewer for entire implementation
4. **MANDATORY:** Load `read_skill("superpowers-verification-before-completion")` — verify all tests pass with evidence before claiming completion
5. Load `read_skill("superpowers-finishing-a-development-branch")` to present completion options

## Sub-Agent Dispatch Pattern

Use this pattern for every sub-agent:

```
# Dispatch
execution_id = spawn_subagent(task="<prompt from template>")

# Wait with timeout
wait_for(interests=[
  {"sub_agent": {"execution_id": execution_id}},
  {"timer": {"duration": "10m"}}
])

# Collect result, then clean up
delete_subagent(execution_id)
```

**Environment isolation:** Use `create_new_environment=false` (shared) for implementers that need to read/write project files. Use `create_new_environment=true` only if sub-agents would conflict (e.g., concurrent git operations).

## Handling Implementer Status

Implementer sub-agents report one of four statuses:

**DONE:** Proceed to spec compliance review.

**DONE_WITH_CONCERNS:** The implementer completed the work but flagged doubts. Read the concerns before proceeding. If the concerns are about correctness or scope, address them before review. If they're observations, note them and proceed.

**NEEDS_CONTEXT:** The implementer needs information that wasn't provided. Provide the missing context and re-dispatch.

**BLOCKED:** The implementer cannot complete the task. Assess the blocker:
1. If it's a context problem, provide more context and re-dispatch
2. If the task is too large, break it into smaller pieces
3. If the plan itself is wrong, escalate to the user

**Never** ignore an escalation or force the same approach to retry without changes.

## Prompt Templates

- `references/implementer-prompt.md` — Dispatch implementer sub-agent
- `references/spec-reviewer-prompt.md` — Dispatch spec compliance reviewer sub-agent
- `references/code-quality-reviewer-prompt.md` — Dispatch code quality reviewer sub-agent

## Red Flags

**Never:**
- Start implementation on main/master branch without explicit user consent
- Skip reviews (spec compliance OR code quality)
- Proceed with unfixed issues
- Dispatch multiple implementation sub-agents in parallel (conflicts)
- Make sub-agent read plan file (provide full text instead)
- Skip scene-setting context (sub-agent needs to understand where task fits)
- Ignore sub-agent questions (answer before letting them proceed)
- Accept "close enough" on spec compliance
- Skip review loops (reviewer found issues = implementer fixes = review again)
- **Start code quality review before spec compliance is ✅** (wrong order)
- Move to next task while either review has open issues

**If sub-agent asks questions:**
- Answer clearly and completely
- Provide additional context if needed
- Don't rush them into implementation

**If reviewer finds issues:**
- Implementer (same sub-agent) fixes them
- Reviewer reviews again
- Repeat until approved
- Don't skip the re-review

**If sub-agent fails task:**
- Dispatch fix sub-agent with specific instructions
- Don't try to fix manually (context pollution)

## Integration

**Required workflow skills:**
- `read_skill("superpowers-using-git-worktrees")` — Ensures isolated workspace
- `read_skill("superpowers-writing-plans")` — Creates the plan this skill executes
- `read_skill("superpowers-requesting-code-review")` — Code review template for reviewer sub-agents
- `read_skill("superpowers-finishing-a-development-branch")` — Complete development after all tasks

**Sub-agents should follow:**
- `read_skill("superpowers-test-driven-development")` — TDD for each task

**Alternative workflow:**
- `read_skill("superpowers-executing-plans")` — Use for inline execution instead of sub-agent-driven
