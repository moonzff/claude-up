# Claude_up

> **A reproducible, auditable Claude Code environment governance toolkit.**
> Dual-scenario: deep software engineering + personal digital assistant.

[![Version](https://img.shields.io/badge/version-v1.0.0-blue)](99-manifest/CHANGELOG.md)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%2011%20%7C%20macOS-lightgrey)](01-global-config/)

[中文文档 →](README_ZH.md)

---

## What Is Claude_up?

Claude_up is a personal environment governance kit for [Claude Code](https://claude.ai/code). It gives you a **version-controlled, portable, dry-run-safe** configuration that you can deploy to any machine in minutes.

Think of it as your Claude Code dotfiles — but with a skill library, a persistent memory system, hook templates, MCP configs, and a diagnostic CLI baked in.

**Two scenarios covered out of the box:**
- 🛠️ **Engineering Dev** — coding, TDD, code review, security audit, API design, debugging
- 🧠 **Personal Assistant** — research archiving, meeting notes, weekly reviews, knowledge management

---

## Core Capabilities

### Skills (02-skills/ · always active)
8 skills loaded every session, covering both scenarios:

| Category | Skills |
|----------|--------|
| Dev | `grill-plan` (requirement clarification v2) · `diagnose` · `dual-environment-workflow` |
| Assistant | `research-object-archive` · `summarize-meeting` · `weekly-review` · `memory-update` |

### Skill Library (10-skill-library/ · on-demand)
10 specialized skills loaded only when needed — no context bloat:

| Skill | Trigger |
|-------|---------|
| `sp-brainstorming` | Before writing any code — clarify design direction |
| `sp-writing-plans` | After design confirmation — write executable task plans |
| `sp-executing-plans` | Execute plans with two-stage review (CLI only) |
| `sp-tdd` | Test-driven development cycle |
| `systematic-debugging` | 4-phase bug investigation (locate → analyze → hypothesize → fix) |
| `verification-before-completion` | Evidence-first before claiming any task done |
| `code-review` | 6-dimension code review (correctness, security, performance, maintainability, tests, architecture) |
| `security-audit` | OWASP Top 10 + Node.js + AWS security scan |
| `api-design` | REST API design conventions (Node.js) |
| `task-master` | Cross-session task persistence for large projects (CLI only) |

### Memory System (08-memory/ · 4-tier)
Persistent knowledge across sessions — no external service needed, pure files:

```
core/        ← Always loaded (4 blocks, char-limited): persona, human, projects, stack
working/     ← Per-project context, loaded on demand
semantic/    ← Distilled patterns + conventions with confidence scores
archive/     ← Append-only logs: decisions, lessons, events
```

Inspired by [Letta](https://github.com/letta-ai/letta) memory block architecture and [agentmemory](https://github.com/rohitg00/agentmemory) design principles — implemented as plain Markdown files.

### Hooks (04-hooks/ · deterministic)
4 hooks enforcing consistent behavior:

| Hook | Trigger | Action |
|------|---------|--------|
| `pre-bash-audit` | PreToolUse(Bash) | Log command to audit.log |
| `post-write-format` | PostToolUse(Write/Edit) | Run prettier |
| `stop-session-summary` | Stop | Write session-log.txt |
| `post-write-research` | PostToolUse on research paths | Prompt ROA archiving |

### MCP Servers (05-mcp/)
5 MCP servers configured (requires Claude Code CLI):

| MCP | Status | Purpose |
|-----|--------|---------|
| `filesystem` | ✅ Active | Local file access |
| `playwright` | ✅ Active | Browser automation |
| `context7` | ✅ Active | Real-time library docs |
| `github` | ⚙️ Needs `GITHUB_TOKEN` env var | GitHub API |
| `letta` | ⚙️ Needs local Letta server | (Optional) Letta memory MCP |

### Deployment Kit (06-deployment-kit/)
Safe, dry-run-first installer with profile selection:

```powershell
# Preview changes (default, no writes)
.\06-deployment-kit\install_claude_app.ps1

# Apply with profile
.\06-deployment-kit\install_claude_app.ps1 -Execute -Profile dev
# Profiles: dev | assistant | full
```

---

## Quick Start

### Prerequisites
- **Windows 11 + PowerShell 7**, or **macOS (Apple Silicon) + zsh**
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed (`npm install -g @anthropic-ai/claude-code`)
- Node.js ≥ 18

> Two global-config profiles are provided: `01-global-config/windows-claude/`
> and `01-global-config/mac-claude/`. Pick the one matching your OS.
> See [`mac-claude/MIGRATION-NOTES.md`](01-global-config/mac-claude/MIGRATION-NOTES.md)
> for a full Windows→macOS migration walkthrough.

<details>
<summary><b>Windows (PowerShell)</b></summary>

```powershell
# 1. Clone
git clone https://github.com/moonzff/claude-up.git D:\YourWorkspace\Claude_up
cd D:\YourWorkspace\Claude_up

# 2. Set up your memory
Copy-Item 08-memory\templates\human.template.md    08-memory\core\human.md
Copy-Item 08-memory\templates\projects.template.md 08-memory\core\projects.md

# 3. Deploy config (dry-run, then apply)
.\06-deployment-kit\install_claude_app.ps1
.\06-deployment-kit\install_claude_app.ps1 -Execute -Profile full

# 4. Verify
.\cli\claude_app.ps1 doctor
```
</details>

<details>
<summary><b>macOS (zsh)</b></summary>

```bash
# 1. Clone
git clone https://github.com/moonzff/claude-up.git ~/MoonzWorkspace/Claude_up
cd ~/MoonzWorkspace/Claude_up

# 2. Set up your memory
cp 08-memory/templates/human.template.md    08-memory/core/human.md
cp 08-memory/templates/projects.template.md 08-memory/core/projects.md

# 3. Deploy config — copy the mac-claude profile into ~/.claude
mkdir -p ~/.claude/commands
cp 01-global-config/mac-claude/CLAUDE.md     ~/.claude/CLAUDE.md
cp 01-global-config/mac-claude/settings.json ~/.claude/settings.json   # review the diff first
cp 03-commands/{diagnose,grill,research,review,weekly}.md ~/.claude/commands/

# 4. Verify
claude --version && ls ~/.claude/{commands,CLAUDE.md,settings.json}
```
</details>

---

## Project Layout

```
Claude_up/
├── 00-overview/          # Research docs and architectural synthesis
├── 01-global-config/     # settings.json + CLAUDE.md templates
│   ├── windows-claude/   # Windows profile
│   └── mac-claude/       # macOS profile (+ MIGRATION-NOTES.md)
├── 02-skills/            # Always-active skills (dev/ + assistant/)
├── 03-commands/          # Slash command templates
├── 04-hooks/             # Hook configs (dev/ + assistant/)
├── 05-mcp/               # MCP server configs + activation guides
├── 06-deployment-kit/    # Installer, bootstrap guide, deploy scripts
├── 08-memory/            # 4-tier memory system
│   ├── core/             # Always-loaded blocks (persona, stack — gitignored: human, projects)
│   ├── working/          # Per-project context (gitignored)
│   ├── semantic/         # Distilled patterns + conventions
│   ├── archive/          # Append-only decision/lesson/event logs
│   └── templates/        # Starter templates for gitignored files
├── 10-skill-library/     # On-demand skill library (INDEX.md + 10 skills)
├── 99-manifest/          # CHANGELOG, VERSION
├── cli/                  # Diagnostic CLI (doctor, mcp-check, skill-list...)
└── tooling/              # Companion tools (ccusage, task-master guide)
```

---

## Design Principles

1. **Think before acting** — No writes before reviewing current state
2. **Simplicity first** — Prefer existing scripts/templates over new dependencies
3. **Surgical changes** — Only touch files the current task requires
4. **Dry-run by default** — Batch operations preview before execute
5. **No secrets in files** — Use `${env:VAR}` placeholders, never hardcode tokens
6. **Zero external services** — Core features work without running servers

---

## Ecosystem References

Built by studying and cherry-picking from:

| Project | What was absorbed |
|---------|------------------|
| [obra/superpowers](https://github.com/obra/superpowers) | sp-brainstorming, sp-writing-plans, sp-executing-plans methodology |
| [Letta](https://github.com/letta-ai/letta) | 3-tier memory block architecture |
| [agentmemory](https://github.com/rohitg00/agentmemory) | 4-tier memory, confidence scoring, memory evolution |
| [jnMetaCode/superpowers-zh](https://github.com/jnMetaCode/superpowers-zh) | systematic-debugging, verification-before-completion |
| [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | Skill patterns and community best practices |

---

## Companion Tools

These tools work alongside Claude_up but are not included:

- **[ccusage](tooling/ccusage.md)** — Token usage and cost tracking (`npx ccusage daily`)
- **[claude-task-master](10-skill-library/dev/task-master/SKILL.md)** — Cross-session task persistence for large projects

---

## License

[MIT](LICENSE) © 2026 Moonz
