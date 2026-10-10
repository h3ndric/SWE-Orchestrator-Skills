# Prior-art research (October 2026)

Question: is there an existing, well-reviewed orchestrator or SWE skill set that can act as a single autonomous "hire", run the full lifecycle, and install into Claude Code, Copilot CLI, Kimi Code, Antigravity and pi?

## Findings

| Project | Stars (approx.) | What it is | Your 5 tools | Autonomy | Lifecycle coverage |
|---|---|---|---|---|---|
| [obra/superpowers](https://github.com/obra/superpowers) | ~290K | A skills workflow: brainstorm → plan → worktree → subagent TDD → review → finish | All 5 (native installers) | Interactive: asks the user design questions | Strong on build discipline. No architecture depth, security, deploy or observability |
| [github/spec-kit](https://github.com/github/spec-kit) | ~126K | Spec-driven development slash commands | 30+ agents | The user drives each phase | Spec → plan → tasks → implement |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | ~104K | 25 lifecycle skills: Define, Plan, Build, Verify, Review, Ship | Most, via `npx skills` | A toolbox with no conductor | Broad: security, CI/CD, observability, launch, ADRs |
| [GSD / GSD Core](https://github.com/open-gsd/gsd-core) | ~64K (archived v1) / ~10K (Core) | A milestone loop: discuss → plan → execute → verify → ship | Claude, Copilot, Kimi, Antigravity, more | Semi-autonomous; its discuss step asks about implementation | Good build loop, limited production coverage |
| [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD) | ~47K | 12+ agile personas (Analyst, PM, Architect, SM, Dev, QA…) | Several | The user drives the personas. Token-heavy | Broad but heavyweight |
| [oh-my-claudecode](https://github.com/yeachan-heo/oh-my-claudecode) | ~40K | Multi-agent orchestration; `/autopilot` goes from idea to tested code | Claude only (calls agy/Codex as helpers) | Fully autonomous, but with no review gates | No requirements sign-off or production readiness |

## Cross-agent compatibility

All 5 target agents read the open **Agent Skills** format: a folder with a `SKILL.md` that has `name` and `description` frontmatter plus Markdown instructions. These folder locations were verified on this machine and in the agents' own docs:

- Claude Code: `~/.claude/skills/`
- Copilot CLI: `~/.copilot/skills/`
- Antigravity CLI: `~/.gemini/config/skills/` (global customization root `~/.gemini/config/`, from its built-in `agy-customizations` docs)
- Antigravity IDE: `~/.gemini/antigravity/skills/`
- Kimi Code and pi: `~/.agents/skills/`

## Harness best practices (and how this project applies them)

These come from Anthropic's long-running-agent harness, OpenAI's harness engineering, and a 2026 survey of 246 agent repositories:

| Practice | Source | Applied here |
|---|---|---|
| Keep progress in files, not context. Every session starts by reading the progress log and git log, then running a basic e2e check | Anthropic | `docs/STATUS.md` plus the session-start routine (`scripts/init.sh`, then `smoke.sh`). A failing smoke test gets fixed first |
| Work on one feature at a time, and leave a clean, committed state each session | Anthropic | Task-level checkpoints, one milestone per session, commit per task |
| A feature list in **JSON** with a pass flag; agents may only flip the flag | Anthropic | `docs/traceability.json`: build agents may only change the status, tests and verification fields |
| Verify as a human user would (browser automation), not just unit tests or curl | Anthropic | Playwright e2e test per user-facing REQ, with the journey exercised in a browser |
| A short AGENTS.md (~100 lines) as a **map**, with `docs/` as the system of record | OpenAI | A template AGENTS.md that points to docs. Doc gardening keeps it short |
| Enforce rules mechanically (linters, structural tests, hooks, CI). Write lint messages that explain the fix | OpenAI, survey | `references/guardrails.md`: `check.sh`, a pre-commit hook, boundary checks from the module register, and "mistake seen twice → check" |
| Separate generation from evaluation; self-grading is unreliable | Survey, Anthropic | Only a verifier other than the implementer can mark an item `pass` |
| Keep handoff chains short (more than 4 handoffs usually fails); extra reviewer layers can hurt | Survey (Microsoft, ablations) | Chains are limited to orchestrator → implementer → verifier |
| Isolate parallel agents (worktree, port, DB) | Survey, OpenAI | Module claims plus per-worktree port and DB rules |
| Garbage collection: recurring doc-drift and tech-debt sweeps | OpenAI | Doc gardening in every increment review, plus `docs/TECH-DEBT.md` |
| Build the harness in reaction to failures, and test it like code | Survey, OpenAI | `docs/HARNESS-LOG.md` plus planned harness evals |
| Fewer, shorter instructions; context is finite | Survey (ETH Zurich), OpenAI | Progressive disclosure: short SKILL.md files, with details in `references/` |

Sources:
- [Anthropic: Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [OpenAI harness engineering (mirror)](https://github.com/celesteanders/harness/blob/main/docs/research/260211_openai_harness_engineering_codex.md)
- [The State of AI Harness Engineering 2026 (marmelab)](https://marmelab.com/blog/2026/09/24/the-state-of-ai-harness-engineering-2026.html)
- [Context engineering guide (latitude)](https://latitude.so/blog/context-engineering-guide-coding-agents)

## Conclusion

Nothing found combines all four requirements:
- (a) a single autonomous lead
- (b) a deep requirements interview, then no further technical questions
- (c) full lifecycle coverage through production
- (d) support for all 5 agents

**Decision:** build a thin custom orchestrator plus specialist roles, and reuse superpowers and part of addy's agent-skills as an optional toolbox. Spec-kit and BMAD were not adopted. Spec-kit overlaps superpowers, and BMAD's ceremony and token cost don't fit a non-engineer who only wants to review at gates.

Star counts are snapshots from public sources around late September and October 2026. They are popularity signals, not quality measures.
