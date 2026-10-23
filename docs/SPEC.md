# SWE Orchestrator Skills: specification

Version 1.0 · 2026-10-10

## 1. Problem

The target user ("the owner") is not a software engineer and hasn't worked through the full software lifecycle. They want to build serious AI software using coding agents they already have:
- Claude Code
- GitHub Copilot CLI
- Kimi Code
- Antigravity
- pi
- Cursor

Out of the box, these agents are good at writing code when told what to do. They are not good at owning a project: finding out what to build, designing it, testing it properly, securing it and launching it.

## 2. Goal

**"Hire one engineer."** The owner hands a goal (an MVP or a full product vision) to a single AI orchestrator, which runs the whole lifecycle by itself. The owner only evaluates, reviews and comments on whether the work matches their goal.

### Success criteria
| ID | Criterion |
|---|---|
| G1 | The same orchestrator works in all 5 agents, installed by one script. |
| G2 | The owner is asked about *what/why* only. After Discovery, no technical questions. |
| G3 | Requirements are captured precisely enough to test, through research plus a structured interview. |
| G4 | Every requirement is traceable to milestones and tests. Launch is blocked until MVP requirements pass. |
| G5 | Covers the full lifecycle: idea → requirements → architecture → build → test → security → deploy → operate. |
| G6 | Work survives session resets and switching between agents. |
| G7 | The owner reviews at exactly 4 gates, each with a brief they can read in under 3 minutes. |

### Non-goals
- Replacing the agents' own coding ability. The orchestrator directs them; it doesn't re-implement them.
- Fully unattended operation across gates. The owner stays in control of scope and budget.
- Building a custom runtime, server or app. This is pure skills (Markdown) plus a shell installer.

## 3. Prior art and build-vs-adopt decision

See [RESEARCH.md](RESEARCH.md). In summary, no existing project met G1, G2, G5 and G7 together. So the orchestrator and roles are **custom**, and they **reuse** two well-reviewed packs as a toolbox:
- **obra/superpowers:** planning, TDD, sub-agent development, debugging, code review
- **addyosmani/agent-skills** (a subset): security, CI/CD, observability, launch, ADRs, API design, performance, frontend

## 4. Architecture

```
┌─────────── any of: Claude · Copilot · Kimi · Antigravity · pi · Cursor ───────────┐
│                                                                                   │
│   swe-orchestrator  (tech lead: state machine, gates, decision policy)            │
│        │ loads / dispatches as sub-agents                                         │
│        ├── Discovery dept:  swe-researcher → swe-business-analyst →               │
│        │                    swe-requirements-engineer                             │
│        ├── swe-architect  +  swe-ai-engineer                                      │
│        ├── swe-implementer → swe-reviewer → swe-security                          │
│        ├── all roles held to: swe-standards (rulebook + Definition of Done)        │
│        └── swe-release-sre                                                        │
│                 │ uses when installed (graceful fallback when not)                │
│                 ├── obra/superpowers                                              │
│                 └── addyosmani/agent-skills (subset)                              │
└───────────────────────────────────┬───────────────────────────────────────────────┘
                                    │ reads/writes
                         project/docs/  (single source of truth)
       STATUS · PRD · ARCHITECTURE · ROADMAP · traceability.json · adr/ · REVIEWS/ · plans/
```

### Key design decisions
| # | Decision | Rationale |
|---|---|---|
| D1 | Use the open **Agent Skills (`SKILL.md`)** format only | It's the one format all 5 agents read natively. Agent-specific frontmatter is avoided. |
| D2 | **Any agent can lead** (owner's choice) | Simpler than a fixed lead agent dispatching to other CLIs. The owner uses whichever tool they like. |
| D3 | **State in project `docs/`**, not in agent memory | It survives context resets, and switching between agents (G6). It's also readable by the owner. |
| D4 | **Roles as separate skills** with an `swe-` prefix | Focused context per role, runnable as sub-agents, and no name clashes with other packs. |
| D5 | **Progressive disclosure** | Each SKILL.md is short (≤ ~75 lines) and detail lives in `references/`. This keeps the agent's context lean. |
| D6 | **Symlink install** from this repo | One source of truth. `git pull` updates every agent at once. |
| D8 | **Context window is a disposable scratchpad** | The orchestrator stays thin, delegates heavy work to fresh-context sub-agents, checkpoints STATUS per task, and restarts sessions at gates or milestones. Long projects can't fit in one context |
| D9 | **Module register (`docs/MODULES.md`) held by the orchestrator** | One place for every module's status, claim, REQs, dependencies, tests and reviews. Single writer, so no conflicting edits. Claims prepare for parallel agents. An increment review every 2–3 milestones keeps the roadmap honest |
| D10 | **Mechanical guardrails over prose** | Scripts, git hooks, CI and boundary checks work identically in all 5 agents, and are followed 100% of the time rather than "usually" (`references/guardrails.md`) |
| D11 | **Independent verification, tamper-resistant JSON ledger** | Self-grading is unreliable, and agents edit Markdown tables too freely (`traceability.json`) |
| D12 | **Standards rulebook (`swe-standards`) with rigor profiles** | Models know best practices but apply them inconsistently. ~140 rules with IDs, a minimum profile (P1 Prototype / P2 Production / P3 High-assurance) and a check method make quality binding, sized to the project's risk, and auditable. The owner picks the profile at Gate 2 |
| D13 | **Owner tasks as a designed deliverable** (`OWNER-TODO.md`) | Non-engineers stall on accounts, payments and keys. All owner tasks are listed at Gate 2 with click-by-click steps and a "needed by" milestone, work continues against fakes, and secrets never pass through chat (`references/owner-tasks.md`) |
| D14 | **Attempt limits, anti-cheat, budgets** | Unsupervised agents loop or weaken tests to get green. 3 attempts → change approach, 5 → blocked; tampering with tests is a critical review finding; milestones at 2× plan stop for a scope check; build and running budgets set at Gate 2 (`references/stuck-and-budget.md`) |
| D15 | **Gate tags as restore points** | Code and docs are both in git, so tagging each approved gate makes "go back to Gate 3" a safe, confirmed one-sentence undo with a backup branch (`references/checkpoints-and-undo.md`) |
| D7 | **Toolbox is optional** | Each role carries enough fallback guidance to work without superpowers or addy. |

## 5. Lifecycle (state machine)

| # | Phase | Roles | Output | Gate |
|---|---|---|---|---|
| 1 | Discovery | researcher → business-analyst → requirements-engineer | `discovery/RESEARCH.md`, `discovery/INTERVIEW.md`, `PRD.md`, `traceability.json` | ★ Gate 1: requirements sign-off |
| 2 | Architecture | architect + ai-engineer | `ARCHITECTURE.md`, `adr/*` | ★ Gate 2: architecture and budget |
| 3 | Roadmap | architect | `ROADMAP.md` (M0 walking skeleton first) | none |
| 4 | Build loop (per milestone) | implementer → reviewer → security → verify | code, tests, `plans/M<n>.md` | ★ Gate 3: milestone demo |
| 5 | Production readiness | release-sre + security + ai-engineer | `LAUNCH.md`, `RUNBOOK.md` | ★ Gate 4: go-live |
| 6 | Operate / iterate | business-analyst → requirements-engineer → architect | PRD changelog, new milestones | Gate 3 per milestone |

Full playbooks: `skills/swe-orchestrator/references/phases.md`.

## 6. Requirements capture (Discovery department)

- **Research before questions.** Competitors, user complaints, table-stakes vs differentiating features, feasibility and costs. Every claim is sourced.
- **Interview rules:**
  - one question per message
  - multiple choice with a recommendation grounded in the research
  - plain language and text mockups
  - "you decide" is always allowed, and gets recorded as an assumption
  - answers are logged immediately to `INTERVIEW.md`
- **Stop condition:** the clarity checklist passes. Every Must feature has a persona, a reason and a testable outcome. There's no TBD and no contradictions. AI features have good and bad examples. Budget, platform and privacy are known. The owner has confirmed the playback.
- **Spec format:**
  - `REQ-NNN` user stories with ≥ 2 Given/When/Then criteria
  - measurable `NFR-NNN`s
  - `AIQ-NNN` AI quality targets with good and bad examples
  - MVP / Later / Out-of-scope lists
  - assumptions and a changelog
  - IDs are never reused

## 7. Traceability

`REQ/NFR/AIQ` → milestone (ROADMAP) → test names containing the ID → status in `traceability.json`.
- Every Gate 3 brief shows the coverage table.
- Gate 4 is blocked while any MVP ID is not ✅.
- AI quality is enforced by an eval suite: a golden set from the owner's examples, deterministic checks plus an LLM judge, and thresholds taken from the AIQ IDs.

## 8. Gate protocol

- The brief goes to `docs/REVIEWS/gate-<N>[-m<k>].md` from a fixed template:
  - a one-paragraph summary
  - what you're approving
  - cost, time and risk
  - the decisions made on the owner's behalf (each one can be overridden)
  - the things only the owner can do
  - the details links
- The agent **stops** after posting the brief. It continues only on explicit approval.
- Feedback is classified as clarification, scope change, design change or bug, and routed to the right role. A large change re-issues the gate.

## 9. Decision policy (autonomy between gates)

Apply these rules in order:
1. PRD constraints
2. the owner's existing assets
3. boring/popular over clever
4. managed over self-hosted
5. a single deployable unit
6. extra care and an ADR for irreversible choices
7. cost-aware
8. secure by default
9. verify current model IDs and APIs from the docs

Escalate only for scope, budget, timeline, legal or user-visible changes, or for credentials and accounts only the owner can provide. Defaults table: `skills/swe-orchestrator/references/decision-policy.md`.

## 10. Installer

`install.sh` is idempotent, with `--dry-run`, `--agents=`, `--skip-superpowers` and `--skip-addy`. Commands:

| Command | Effect |
|---|---|
| `install` (default) | Symlinks `skills/*` into each detected agent's global skills folder, installs superpowers via each agent's plugin manager, and installs the addy subset via `npx skills add` |
| `update` | `git pull` this repo, re-link the skills, refresh the toolbox |
| `init <dir>` | Optional. Scaffold `docs/`, `AGENTS.md` and `CLAUDE.md` into a project, and run `git init`. The orchestrator does this itself on first run (Step 0), so the script is only a convenience |
| `status` | Show the link counts per folder |
| `uninstall` | Remove our symlinks (the toolbox packs are left alone) |

Skill folders:

| Agent | Folder |
|---|---|
| Claude Code | `~/.claude/skills/` |
| Copilot CLI | `~/.copilot/skills/` |
| Antigravity | `~/.gemini/config/skills/` (CLI) and `~/.gemini/antigravity/skills/` (IDE) |
| Kimi Code, pi, Cursor | `~/.agents/skills/` |
| Any of the above on Windows | The same folders under `%USERPROFILE%`. `install.ps1` links them with junctions; from WSL, `install.sh` runs `install.ps1`, which makes marked copies |

It never overwrites a file it didn't create.

### In-agent install (plugin manifests)
Manifests let each agent install the repo straight from GitHub. Like superpowers, it uses the agent's own plugin format:

| File | Used by |
|---|---|
| `.claude-plugin/plugin.json` + `marketplace.json` | Claude Code, Copilot CLI |
| `.antigravity-plugin/plugin.json` | Antigravity |
| `.kimi-plugin/plugin.json` | Kimi Code (includes the tool mapping: AskUserQuestion, Agent subagent types) |
| `package.json` → `pi.skills` | pi |
| `.cursor-plugin/plugin.json` | Cursor (for a Cursor Marketplace listing; local installs use `~/.agents/skills/`) |

Use either the plugin route or the symlink route on a machine, not both, to avoid duplicate skills.

## 11. Repository layout

```
install.sh                    installer (Linux, macOS, WSL; from WSL it also runs install.ps1 for Windows-side agents)
install.ps1                   installer for the Windows versions of all 6 agents
scripts/harness-review.sh     scheduled harness review (cron, or Windows Task Scheduler from WSL)
scripts/harness-review.ps1    the same for Windows without WSL
README.md                     overview + quick start
docs/SPEC.md                  this document
docs/RESEARCH.md              prior-art research and build-vs-adopt rationale
docs/USER-GUIDE.md            step-by-step guide for the owner
skills/
  swe-orchestrator/           SKILL.md, references/{phases,gates,decision-policy,subagents}.md,
                              templates/ (AGENTS.md, CLAUDE.md, docs/ skeleton)
  swe-researcher/  swe-business-analyst/ (+ references/question-bank, clarity-checklist)
  swe-requirements-engineer/  swe-architect/  swe-ai-engineer/
  swe-implementer/  swe-reviewer/  swe-security/  swe-release-sre/
  swe-standards/              the rulebook
  swe-harness-review/         turns logged lessons into skill fixes (self-improvement loop)
```

## 12. Verification

| Check | Status (2026-10-10) |
|---|---|
| Frontmatter valid: name matches folder, description ≤ 1024 characters | ✅ all 12 |
| `install.sh --dry-run`, then a real install, links skills into all 5 agents | ✅ |
| superpowers installed: Claude, Copilot, Antigravity, pi | ✅. Kimi needs the manual `/plugins install` |
| Discovery smoke test: each agent names `swe-orchestrator` and Step 0 | ✅ Claude, Copilot, Kimi, Antigravity, pi. ⬜ Cursor (added 2026-10-16, not yet tested in Cursor itself) |
| Windows installers: `install.ps1` for all 6 agents (junctions; copy fallback from a WSL path; refresh; leaves foreign folders alone; `-Agents` filter; uninstall) and `install.sh` handing the Windows side to it | ✅ tested on Windows from WSL with temp home folders (2026-10-16). ⬜ with real Windows agent installs and superpowers via Windows CLIs |
| Self-improvement loop: runners (due/no-change/dirty-repo/failure logic, cron, Windows Task Scheduler from WSL and native) | ✅ tested 2026-10-16 with a stand-in agent and test tasks |
| End-to-end: a real idea taken to Gate 1 → Gate 4 | ⬜ not yet run |
| Resume across agents: stop in one agent, "continue" in another | ⬜ not yet run |

## 13. Roadmap for this project

- **v1.1:**
  - record real failures in `docs/HARNESS-LOG.md` and build 20–50 frozen harness eval tasks from them
  - run the end-to-end and cross-agent resume tests
  - tune the skills based on what happens
  - add `claude plugin eval` cases for the orchestrator's gate behavior
  - candidates borrowed from ECC (RESEARCH.md), only if the pilot shows a need:
    - right-sizing: post-launch change requests get a lighter path by size (trivial / small / standard / large). Anything touching security or a public API counts as at least standard.
    - an optional AgentShield (`ecc-agentshield`) scan in the pre-launch security audit when the product ships agent configs, hooks or MCP settings
  - after the first real-project trial, adjusted by what it shows: a clickable prototype before building (Gate 1/2), a live preview link at every Gate 3, hard limits on live systems and money (production access needs owner approval), and a post-launch learning loop for the *product* (user feedback and success metrics feeding v2). The harness's own learning loop shipped in v1.0: HARNESS-FEEDBACK.md + `swe-harness-review`
- **v1.2:** optional "lead + workers" mode, where the orchestrator dispatches build tasks to other agents' headless CLIs (`kimi -p`, `copilot -p`, `pi -p`).
