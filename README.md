# SWE Orchestrator Skills: hire an AI engineering team

A skill pack that turns **Claude Code, GitHub Copilot CLI, Kimi Code, Antigravity, pi, or Cursor** into an autonomous tech lead. It takes your idea from research and a requirements interview all the way to a tested, secured, production-ready product.

**You** decide *what* and *why*. **It** decides *how*. You only review at 4 gates.

```
 Your idea
    │
    ▼
 ① Discovery ── Researcher ─► Business Analyst interview ─► Requirements spec (PRD)
    │                                                  ★ Gate 1: you sign off the requirements
    ▼
 ② Architecture ── Architect + AI Engineer ─► stack, design, costs, risks
    │                                                  ★ Gate 2: you approve the plan & budget
    ▼
 ③ Roadmap ── milestones mapped to requirement IDs (automatic)
    ▼
 ④ Build loop (per milestone) ── Implementer (TDD) ─► Reviewer ─► Security ─► Verify
    │                                                  ★ Gate 3: you try the demo
    ▼
 ⑤ Production readiness ── Release/SRE ─► CI/CD, monitoring, backups, evals, runbook
                                                       ★ Gate 4: you approve go-live
```

📖 **New here? Read the [User Guide](docs/USER-GUIDE.md).** Design: [Spec](docs/SPEC.md) · [Research](docs/RESEARCH.md)

## Install (once)

**Option A: let an agent do it (no terminal needed).** Open any one of your agents and paste:

> Install the skills from https://github.com/h3ndric/SWE-Orchestrator-Skills: clone it to ~/dev/SWE-Orchestrator-Skills and run its ./install.sh, then show me ./install.sh status.

That one agent installs the team into **all 6** agents, along with the toolbox packs.

**Option B: install as a plugin, one agent at a time.** Type these inside each agent:

| Agent | Command |
|---|---|
| Claude Code | `/plugin marketplace add h3ndric/SWE-Orchestrator-Skills` then `/plugin install swe-orchestrator@swe-orchestrator` |
| Copilot CLI | `copilot plugin marketplace add h3ndric/SWE-Orchestrator-Skills` then `copilot plugin install swe-orchestrator@swe-orchestrator` |
| Antigravity | `agy plugin install https://github.com/h3ndric/SWE-Orchestrator-Skills` |
| Kimi Code | `/plugins install https://github.com/h3ndric/SWE-Orchestrator-Skills` |
| pi | `pi install git:github.com/h3ndric/SWE-Orchestrator-Skills` |
| Cursor | Not needed: Cursor reads `~/.agents/skills/`, so Option A or C covers it (see **Cursor on Windows** below). A `.cursor-plugin/plugin.json` is included for a future Cursor Marketplace listing. |

Option B installs only the `swe-*` skills, not the toolbox packs. **Use one option per machine, not both**, or each skill will show up twice.

**Option C: run the script yourself:**

```bash
git clone https://github.com/h3ndric/SWE-Orchestrator-Skills.git ~/dev/SWE-Orchestrator-Skills
cd ~/dev/SWE-Orchestrator-Skills
./install.sh --dry-run     # preview
./install.sh               # install into every agent it finds
./install.sh status        # check
./install.sh update        # later: pull latest from GitHub + refresh all agents
```

What it installs:

| Pack | What for | How |
|---|---|---|
| `swe-*` skills (this repo) | The orchestrator plus 9 specialist roles | Symlinked, so editing this repo updates all agents |
| [obra/superpowers](https://github.com/obra/superpowers) | Disciplined planning, TDD, sub-agents, debugging, code review | Each agent's own plugin command |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) (subset) | Security, CI/CD, observability, launch, ADRs, API design, performance, frontend | `npx skills add` |

The toolbox packs are optional. The `swe-*` skills fall back to their own guidance if they're missing. To skip them, use `--skip-superpowers` / `--skip-addy`. To target only some agents, use `--agents=claude,kimi`.

**Kimi Code:** superpowers must be installed from inside Kimi with `/plugins install https://github.com/obra/superpowers`. **Cursor:** run `/add-plugin superpowers` in Cursor Agent chat. The installer reminds you.

Where the skills go:

| Agent | Global skills folder |
|---|---|
| Claude Code | `~/.claude/skills/` |
| GitHub Copilot CLI | `~/.copilot/skills/` |
| Antigravity | `~/.gemini/config/skills/` (CLI) and `~/.gemini/antigravity/skills/` (IDE) |
| Kimi Code, pi, Cursor | `~/.agents/skills/` |

**Cursor on Windows.** Both setups are covered:
- **Windows only (no WSL):** clone the repo with Git for Windows, then in PowerShell run `powershell -ExecutionPolicy Bypass -File install.ps1`. It links the skills into `%USERPROFILE%\.agents\skills` with directory junctions (no admin needed). Later: `install.ps1 update`, `status` or `uninstall`.
- **WSL:** run `./install.sh` inside WSL. If Cursor is installed on Windows, it links the skills in WSL (for Cursor's WSL connection) and also copies them into the Windows `%USERPROFILE%\.agents\skills` (Windows apps can't follow WSL links). Run `./install.sh update` after pulling changes to refresh the copies.

## Start a project

```bash
mkdir -p ~/dev/my-ai-app && cd ~/dev/my-ai-app
claude          # or: copilot / kimi / agy / pi / cursor-agent (or open the folder in Cursor)
```

Then say:

> /swe-orchestrator I want to build an app that summarizes my meeting recordings and emails action items to attendees. MVP first.

There's nothing to set up first: on its first run the orchestrator creates `docs/`, `AGENTS.md` and a git repo by itself. Prefer a script? `./install.sh init <dir>` does the same thing ahead of time.

What happens next:
1. It **researches** similar products, then **interviews you** one simple multiple-choice question at a time, about *what* you want, never *how*. Answer "you decide" whenever you like.
2. It writes the requirements spec and stops at **Gate 1** with a one-page brief in `docs/REVIEWS/gate-1.md`.
3. Reply **"approved"**, or with comments in plain language. It updates the plan and carries on by itself to the next gate.

## Resuming and switching agents

Everything lives in your project's `docs/` folder:
- `STATUS.md` holds where things stand and the next action
- `PRD.md`, `ARCHITECTURE.md`, `ROADMAP.md`, `traceability.json`, `adr/`, `REVIEWS/`

Open the project in **any** of the 6 agents and say **"continue"**. It picks up where the last one stopped. A practical split: use Claude for discovery, architecture and reviews, and a cheaper agent for long build milestones.

## How "built as specified" is enforced

- Every requirement gets an ID (`REQ-012`) with Given/When/Then acceptance criteria.
- Every milestone lists the IDs it delivers, and every test names the ID it proves.
- Each milestone demo shows a table: requirement → built? → test passing?
- AI features get an **eval suite** with quality targets (`AIQ-*`) taken from your own good and bad examples.
- Go-live is blocked until every MVP requirement is ✅.

## The team

| Skill | Role |
|---|---|
| `swe-orchestrator` | Tech lead: runs the lifecycle, owns `docs/STATUS.md` and `docs/MODULES.md`, runs the gates |
| `swe-standards` | The rulebook: ~140 rules with IDs from ISO 25010, OWASP Top 10:2025, ASVS 5.0, OWASP LLM Top 10, SLSA, SRE, WCAG 2.2, privacy by design. Includes rigor profiles P1–P3 and the Definition of Done |
| `swe-researcher` | Market, competitor and feasibility research before the interview |
| `swe-business-analyst` | Plain-language requirements interview with a clarity checklist |
| `swe-requirements-engineer` | Testable PRD with REQ/NFR/AIQ IDs and traceability |
| `swe-architect` | Stack, design, ADRs, cost, risks, milestone roadmap |
| `swe-ai-engineer` | LLM design, prompts, RAG, guardrails, evals, AI cost |
| `swe-implementer` | TDD implementation, REQ-tagged tests |
| `swe-reviewer` | Spec compliance and code-quality review |
| `swe-security` | Per-milestone security checks and pre-launch audit |
| `swe-release-sre` | CI/CD, deploy, monitoring, backups, runbook, go-live checklist |

## Uninstall

```bash
./install.sh uninstall     # removes the swe-* symlinks; toolbox packs are left alone
```

## Customizing

Edit the files under `skills/`. Changes are live in every agent immediately, because the skills are symlinked. Good first tweaks:
- `skills/swe-orchestrator/references/decision-policy.md`: your preferred stack and defaults
- `skills/swe-business-analyst/references/question-bank.md`: questions you always want asked
