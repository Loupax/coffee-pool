# Barista Billiards — Claude Code Config

Claude Code configuration for the Barista Billiards PICO-8 game.

## Agents

| Agent | Model | maxTurns | Purpose |
|---|---|---|---|
| **orchestrator** | opus | — | Coordinates complex multi-step tasks. Breaks work into subtasks, delegates to developer and qa, then summarizes. |
| **developer** | sonnet | 20 | Implements scoped tasks: writes and edits PICO-8 Lua code in `barista.p8`. |
| **qa** | haiku | 20 | Validates implementation. Checks correctness, consistency, completeness, and token budget. Returns PASS / FAIL / PASS WITH NOTES. |

## Skills (slash commands)

### `/implement <task>`
Runs the full orchestrator → developer → qa pipeline.

### `/review [target]`
Runs the qa agent to validate the cart.

## Structure

```
.claude/
├── README.md
├── agents/
│   ├── orchestrator.md
│   ├── developer.md
│   └── qa.md
└── skills/
    ├── implement/SKILL.md
    └── review/SKILL.md
```
