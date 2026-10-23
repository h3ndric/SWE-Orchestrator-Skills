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
| [ECC](https://github.com/affaan-m/ECC) (reviewed Oct 2026, v2.2.3) | ~287K | A large developer toolbox and runtime: 71 agents, 311 skills, 97 commands, hooks, memory, continuous learning, AgentShield scanner | Claude Code stable; Codex/Qoder native; Cursor, OpenCode, Copilot beta; Kimi, Antigravity, Pi minimal | Developer-driven commands; `orch-*` pipelines with two technical gates (approve plan, confirm commit) | Strong plan → TDD → review → commit; starts from an existing spec, no discovery interview or owner launch gate |

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

## Standards embedded in `swe-standards`

| Area | Baseline | Rule IDs |
|---|---|---|
| Quality model / NFRs | ISO/IEC 25010:2023 (9 characteristics) | QA-01…09 |
| Architecture | C4 model, 12-factor, modular monolith, RFC 9457 errors, ADRs | ARC-01…15 |
| Code quality | Google engineering practices (code review standard), Conventional Commits, SemVer | CQ-01…16 |
| Testing | Test pyramid, coverage floors, e2e journeys, contract and mutation testing | TST-01…15 |
| Security | [OWASP Top 10:2025](https://owasp.org/Top10/2025/), [OWASP ASVS 5.0](https://owasp.org/www-project-application-security-verification-standard/) (L1/L2/L3 by profile) | SEC-01…16 |
| AI / LLM | [OWASP Top 10 for LLM Apps 2025](https://genai.owasp.org/llm-top-10/), NIST AI RMF (P3) | AI-01…17 |
| Supply chain | [SLSA](https://slsa.dev/), NIST SSDF (SP 800-218), OpenSSF Scorecard, SBOM (CycloneDX/SPDX) | SUP-01…11 |
| Reliability / ops | Google SRE (SLOs, error budgets, symptom alerting), DORA four keys | OPS-01…15 |
| Accessibility / UX | [WCAG 2.2](https://www.w3.org/TR/WCAG22/) AA | A11Y-01…08, UX-01…05 |
| Privacy | GDPR principles / privacy by design (engineering guidance, not legal advice) | PRV-01…11 |

## Conclusion

Nothing found combines all four requirements:
- (a) a single autonomous lead
- (b) a deep requirements interview, then no further technical questions
- (c) full lifecycle coverage through production
- (d) support for all 5 agents

**Decision:** build a thin custom orchestrator plus specialist roles, and reuse superpowers and part of addy's agent-skills as an optional toolbox. Spec-kit and BMAD were not adopted. Spec-kit overlaps superpowers, and BMAD's ceremony and token cost don't fit a non-engineer who only wants to review at gates.

### ECC (reviewed October 2026)

ECC is the most comprehensive *toolbox* found, but not a replacement for this project. It's built for developers who drive the agent with commands and approve each plan and commit. It doesn't find out what to build from a non-technical owner, and it doesn't run the lifecycle on its own behind a few plain-language gates. Installing it alongside these skills would add competing flows (`plan`, `code-review`, `orch-*` with their own gates). It would also add global hooks, which change agent behavior in every project, and a large context footprint, which hurts most on small local models where ECC's support is minimal. Its hook-based learning is Claude-Code-specific and has no approval step, while this project's lesson → reviewed-PR loop fits a public, multi-agent repo.

Two ideas are worth borrowing if the pilot shows a need (see SPEC §13): **right-sizing** ceremony to the size of a change, and **AgentShield** (`ecc-agentshield`) as an optional scanner for AI-agent configs in the pre-launch security audit.

Star counts are snapshots from public sources around late September and October 2026. They are popularity signals, not quality measures.
