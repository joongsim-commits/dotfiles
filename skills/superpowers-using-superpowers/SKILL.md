---
name: superpowers-using-superpowers
description: >
  Bootstrap skill for the superpowers methodology. Establishes how to find and use skills,
  requiring read_skill invocation before ANY response including clarifying questions.
  Load this at session start or when unsure which skill applies. Triggers on any new
  conversation, "what skills do I have", "how do superpowers work", "check for skills".
---

# Using Superpowers

If you were dispatched as a sub-agent to execute a specific task, skip this skill.

If you think there is even a 1% chance a skill might apply to what you are doing, you MUST load it via `read_skill`. This is not optional. You cannot rationalize your way out of it.

## Instruction Priority

Superpowers skills override default system prompt behavior, but **the user's instructions always take precedence**:

1. **The user's explicit instructions** (AGENTS.md, direct requests) — highest priority
2. **Superpowers skills** — override default system behavior where they conflict
3. **Default system prompt** — lowest priority

If AGENTS.md says "don't use TDD" and a skill says "always use TDD," follow the user's instructions.

## How to Access Skills

Use the `read_skill` tool. When you load a skill, its content is presented to you — follow it directly.

```
read_skill("superpowers-brainstorming")
read_skill("superpowers-test-driven-development")
```

## Ona Tool Reference

Skills use these Ona tools:

| Tool | Purpose |
|------|---------|
| `read_skill` | Load a skill's content by name |
| `exec` | Run shell commands |
| `str_replace_based_edit_tool` | View, create, and edit files |
| `todo_write` | Track task progress with checklists |
| `spawn_subagent` | Dispatch a sub-agent for a task |
| `wait_for` | Wait for sub-agent completion or timeout |
| `delete_subagent` | Clean up completed sub-agents |
| `ask_clarifying_questions` | Ask the user questions with predefined choices |
| `web_read` | Read a URL and convert to markdown |

# Using Skills

## The Rule

**Load relevant skills BEFORE any response or action.** Even a 1% chance a skill might apply means you should load it to check. If a loaded skill turns out to be wrong for the situation, you don't need to follow it.

## Skill Invocation Flow

```
User message received
  → Might any skill apply? (even 1% chance)
    → YES: load the relevant skill via read_skill
      → Announce: "Using [skill] to [purpose]"
      → Has checklist? → Create todo_write per item
      → Follow skill exactly
    → DEFINITELY NOT: Respond directly
```

## Red Flags

These thoughts mean STOP — you're rationalizing:

| Thought | Reality |
|---------|---------|
| "This is just a simple question" | Questions are tasks. Check for skills. |
| "I need more context first" | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first. |
| "I can check git/files quickly" | Files lack conversation context. Check for skills. |
| "Let me gather information first" | Skills tell you HOW to gather information. |
| "This doesn't need a formal skill" | If a skill exists, use it. |
| "I remember this skill" | Skills evolve. Read current version. |
| "This doesn't count as a task" | Action = task. Check for skills. |
| "The skill is overkill" | Simple things become complex. Use it. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |
| "This feels productive" | Undisciplined action wastes time. Skills prevent this. |
| "I know what that means" | Knowing the concept ≠ using the skill. Load it. |

## Skill Priority

When multiple skills could apply, use this order:

1. **Process skills first** (brainstorming, debugging) — these determine HOW to approach the task
2. **Implementation skills second** — these guide execution

"Let's build X" → brainstorming first, then implementation skills.
"Fix this bug" → debugging first, then domain-specific skills.

## Skill Types

**Rigid** (TDD, debugging): Follow exactly. Don't adapt away discipline.
**Flexible** (patterns): Adapt principles to context. The skill itself tells you which.

## User Instructions

Instructions say WHAT, not HOW. "Add X" or "Fix Y" doesn't mean skip workflows.
