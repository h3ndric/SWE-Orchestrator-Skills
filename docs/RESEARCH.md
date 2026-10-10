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

## Conclusion

Nothing found combines all four requirements:
- (a) a single autonomous lead
- (b) a deep requirements interview, then no further technical questions
- (c) full lifecycle coverage through production
- (d) support for all 5 agents

**Decision:** build a thin custom orchestrator plus specialist roles, and reuse superpowers and part of addy's agent-skills as an optional toolbox. Spec-kit and BMAD were not adopted. Spec-kit overlaps superpowers, and BMAD's ceremony and token cost don't fit a non-engineer who only wants to review at gates.

Star counts are snapshots from public sources around late September and October 2026. They are popularity signals, not quality measures.
