---
name: superpowers-dispatching-parallel-agents
description: >
  Use when facing 2+ independent tasks that can be worked on without shared state or
  sequential dependencies. Dispatches one sub-agent per problem domain for concurrent
  work. Triggers on "parallel", "concurrent", "multiple failures", "independent tasks",
  "run these at the same time".
---

# Dispatching Parallel Agents

## Overview

You delegate tasks to specialized agents with isolated context. By precisely crafting their instructions and context, you ensure they stay focused and succeed. They should never inherit your session's context or history — you construct exactly what they need.

When you have multiple unrelated failures (different test files, different subsystems, different bugs), investigating them sequentially wastes time. Each investigation is independent and can happen in parallel.

**Core principle:** Dispatch one agent per independent problem domain. Let them work concurrently.

## When to Use

**Use when:**
- 3+ test files failing with different root causes
- Multiple subsystems broken independently
- Each problem can be understood without context from others
- No shared state between investigations

**Don't use when:**
- Failures are related (fix one might fix others)
- Need to understand full system state
- Agents would interfere with each other

## The Pattern

### 1. Identify Independent Domains

Group failures by what's broken:
- File A tests: Tool approval flow
- File B tests: Batch completion behavior
- File C tests: Abort functionality

Each domain is independent — fixing tool approval doesn't affect abort tests.

### 2. Create Focused Agent Tasks

Each agent gets:
- **Specific scope:** One test file or subsystem
- **Clear goal:** Make these tests pass
- **Constraints:** Don't change other code
- **Expected output:** Summary of what you found and fixed

### 3. Dispatch in Parallel

```
# Spawn all agents
id_1 = spawn_subagent(task="Fix agent-tool-abort.test.ts failures...")
id_2 = spawn_subagent(task="Fix batch-completion-behavior.test.ts failures...")
id_3 = spawn_subagent(task="Fix tool-approval-race-conditions.test.ts failures...")

# Wait for each (with timeouts)
wait_for(interests=[
  {"sub_agent": {"execution_id": id_1}},
  {"timer": {"duration": "10m"}}
])
# ... repeat for id_2, id_3
```

**Environment isolation:** Use `create_new_environment=true` when sub-agents might edit the same files or run conflicting git operations. Use shared environment (`create_new_environment=false`) when sub-agents only read shared files and write to non-overlapping areas.

### 4. Review and Integrate

When agents return:
- Read each summary
- Verify fixes don't conflict
- Run full test suite via `exec`
- Integrate all changes

**Clean up:** Call `delete_subagent` for each completed sub-agent.

## Agent Prompt Structure

Good agent prompts are:
1. **Focused** — One clear problem domain
2. **Self-contained** — All context needed to understand the problem
3. **Specific about output** — What should the agent return?

```markdown
Fix the 3 failing tests in src/agents/agent-tool-abort.test.ts:

1. "should abort tool with partial output capture" - expects 'interrupted at' in message
2. "should handle mixed completed and aborted tools" - fast tool aborted instead of completed
3. "should properly track pendingToolCount" - expects 3 results but gets 0

These are timing/race condition issues. Your task:
1. Read the test file and understand what each test verifies
2. Identify root cause - timing issues or actual bugs?
3. Fix by replacing arbitrary timeouts with event-based waiting
4. Do NOT just increase timeouts - find the real issue.

Return: Summary of what you found and what you fixed.
```

## Common Mistakes

**❌ Too broad:** "Fix all the tests" — agent gets lost
**✅ Specific:** "Fix agent-tool-abort.test.ts" — focused scope

**❌ No context:** "Fix the race condition" — agent doesn't know where
**✅ Context:** Paste the error messages and test names

**❌ No constraints:** Agent might refactor everything
**✅ Constraints:** "Do NOT change production code" or "Fix tests only"

## Verification

After agents return:
1. **Review each summary** — Understand what changed
2. **Check for conflicts** — Did agents edit same code?
3. **Run full suite** — Verify all fixes work together via `exec`
4. **Spot check** — Agents can make systematic errors
