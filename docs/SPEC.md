# SWE Orchestrator Skills: specification

Version 1.0 · 2026-10-10

## 1. Problem

The owner is not a software engineer and has never worked through the full software lifecycle. They want to build serious AI software using the coding agents they already have:
- Claude Code
- GitHub Copilot CLI
- Kimi Code
- Antigravity
- pi

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
┌──────────────── any of: Claude · Copilot · Kimi · Antigravity · pi ───────────────┐
│                                                                                   │
│   swe-orchestrator  (tech lead: state machine, gates, decision policy)            │
│        │ loads / dispatches as sub-agents                                         │
│        ├── Discovery dept:  swe-researcher → swe-business-analyst →               │
│        │                    swe-requirements-engineer                             │
│        ├── swe-architect  +  swe-ai-engineer                                      │
│        ├── swe-implementer → swe-reviewer → swe-security                          │
│        └── swe-release-sre                                                        │
│                 │ uses when installed (graceful fallback when not)                │
│                 ├── obra/superpowers                                              │
│                 └── addyosmani/agent-skills (subset)                              │
└───────────────────────────────────┬───────────────────────────────────────────────┘
                                    │ reads/writes
                         project/docs/  (single source of truth)
       STATUS · PRD · ARCHITECTURE · ROADMAP · TRACEABILITY · adr/ · REVIEWS/ · plans/
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
| D7 | **Toolbox is optional** | Each role carries enough fallback guidance to work without superpowers or addy. |

## 5. Lifecycle (state machine)

| # | Phase | Roles | Output | Gate |
|---|---|---|---|---|
| 1 | Discovery | researcher → business-analyst → requirements-engineer | `discovery/RESEARCH.md`, `discovery/INTERVIEW.md`, `PRD.md`, `TRACEABILITY.md` | ★ Gate 1: requirements sign-off |
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

`REQ/NFR/AIQ` → milestone (ROADMAP) → test names containing the ID → status in `TRACEABILITY.md`.
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
| Kimi Code, pi | `~/.agents/skills/` |

It never overwrites a file it didn't create.

### In-agent install (plugin manifests)
Manifests let each agent install the repo straight from GitHub. Like superpowers, it uses the agent's own plugin format:

| File | Used by |
|---|---|
| `.claude-plugin/plugin.json` + `marketplace.json` | Claude Code, Copilot CLI |
| `.antigravity-plugin/plugin.json` | Antigravity |
| `.kimi-plugin/plugin.json` | Kimi Code (includes the tool mapping: AskUserQuestion, Agent subagent types) |
| `package.json` → `pi.skills` | pi |

Use either the plugin route or the symlink route on a machine, not both, to avoid duplicate skills.

## 11. Repository layout

```
install.sh                    installer
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
```

## 12. Verification

| Check | Status (2026-10-10) |
|---|---|
| Frontmatter valid: name matches folder, description ≤ 1024 characters | ✅ all 10 |
| `install.sh --dry-run`, then a real install, links skills into all 5 agents | ✅ |
| superpowers installed: Claude, Copilot, Antigravity, pi | ✅. Kimi needs the manual `/plugins install` |
| Discovery smoke test: each agent names `swe-orchestrator` and Step 0 | ✅ Claude, Copilot, Kimi, Antigravity, pi |
| End-to-end: a real idea taken to Gate 1 → Gate 4 | ⬜ not yet run |
| Resume across agents: stop in one agent, "continue" in another | ⬜ not yet run |

## 13. Roadmap for this project

- **v1.1:**
  - run the end-to-end and cross-agent resume tests
  - tune the skills based on what happens
  - add `claude plugin eval` cases for the orchestrator's gate behavior
- **v1.2:** optional "lead + workers" mode, where the orchestrator dispatches build tasks to other agents' headless CLIs (`kimi -p`, `copilot -p`, `pi -p`).
