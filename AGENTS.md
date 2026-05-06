# Superpowers Bootstrap

You have access to a set of superpowers skills that enforce disciplined development workflows. These skills are mandatory — not suggestions.

## Core Rules

1. **Check for skills before any response.** Before answering, coding, debugging, or planning, check if a superpowers skill applies. Even a 1% chance means you should load it via `read_skill`.
2. **Priority order:** The user's explicit instructions (this file, direct requests) take precedence over skills, which take precedence over default behavior.
3. **Invoke, don't skip.** If a skill applies, load it and follow it. You cannot rationalize your way out of using a skill.

## Available Skills

Load any skill via `read_skill("skill-name")`:

| Skill | When to use |
|---|---|
| `superpowers-using-superpowers` | Full bootstrap details, red flags table, skill invocation flow |
| `superpowers-brainstorming` | Before any creative/feature work — design before code |
| `superpowers-writing-plans` | After design approval — create implementation plan |
| `superpowers-subagent-driven-development` | Execute plans via sub-agents with two-stage review |
| `superpowers-executing-plans` | Execute plans inline (fallback when sub-agents not preferred) |
| `superpowers-test-driven-development` | During any implementation — RED-GREEN-REFACTOR |
| `superpowers-systematic-debugging` | When encountering any bug or unexpected behavior |
| `superpowers-verification-before-completion` | Before claiming work is done — evidence before assertions |
| `superpowers-dispatching-parallel-agents` | When facing 2+ independent tasks that can run concurrently |
| `superpowers-requesting-code-review` | After completing tasks — dispatch reviewer sub-agent |
| `superpowers-receiving-code-review` | When receiving review feedback — verify before implementing |
| `superpowers-using-git-worktrees` | Before feature work — ensure branch isolation |
| `superpowers-finishing-a-development-branch` | When implementation is complete — merge/PR/keep/discard |

## Quick Start

For the full skill invocation flow, red flags table, and detailed guidance, load the bootstrap skill:

```
read_skill("superpowers-using-superpowers")
```
