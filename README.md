# SWE Orchestrator Skills: hire an AI engineering team

A skill pack that turns **Claude Code, GitHub Copilot CLI, Kimi Code, Antigravity, or pi** into an autonomous tech lead. It takes your idea from research and a requirements interview all the way to a tested, secured, production-ready product.

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

**Kimi Code:** superpowers must be installed from inside Kimi with `/plugins install https://github.com/obra/superpowers`. The installer reminds you.

Where the skills go:

| Agent | Global skills folder |
|---|---|
| Claude Code | `~/.claude/skills/` |
| GitHub Copilot CLI | `~/.copilot/skills/` |
| Antigravity | `~/.gemini/config/skills/` (CLI) and `~/.gemini/antigravity/skills/` (IDE) |
| Kimi Code, pi | `~/.agents/skills/` |

## Start a project

```bash
./install.sh init ~/dev/my-ai-app      # creates docs/ skeleton + AGENTS.md + git repo
cd ~/dev/my-ai-app
claude          # or: copilot / kimi / agy / pi
```

Then say:

> /swe-orchestrator I want to build an app that summarizes my meeting recordings and emails action items to attendees. MVP first.

(`init` is optional. The orchestrator creates the `docs/` skeleton itself if it's missing.)

What happens next:
1. It **researches** similar products, then **interviews you** one simple multiple-choice question at a time, about *what* you want, never *how*. Answer "you decide" whenever you like.
2. It writes the requirements spec and stops at **Gate 1** with a one-page brief in `docs/REVIEWS/gate-1.md`.
3. Reply **"approved"**, or with comments in plain language. It updates the plan and carries on by itself to the next gate.

## Resuming and switching agents

Everything lives in your project's `docs/` folder:
- `STATUS.md` holds where things stand and the next action
- `PRD.md`, `ARCHITECTURE.md`, `ROADMAP.md`, `TRACEABILITY.md`, `adr/`, `REVIEWS/`

Open the project in **any** of the 5 agents and say **"continue"**. It picks up where the last one stopped. A practical split: use Claude for discovery, architecture and reviews, and a cheaper agent for long build milestones.

## How "built as specified" is enforced

- Every requirement gets an ID (`REQ-012`) with Given/When/Then acceptance criteria.
- Every milestone lists the IDs it delivers, and every test names the ID it proves.
- Each milestone demo shows a table: requirement → built? → test passing?
- AI features get an **eval suite** with quality targets (`AIQ-*`) taken from your own good and bad examples.
- Go-live is blocked until every MVP requirement is ✅.

## The team

| Skill | Role |
|---|---|
| `swe-orchestrator` | Tech lead: runs the lifecycle, owns `docs/STATUS.md`, runs the gates |
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
