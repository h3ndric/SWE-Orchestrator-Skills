# Agent instructions

This project is run by the **swe-orchestrator** skill: an autonomous tech lead working for a non-technical owner.

**Any agent (Claude Code, Copilot, Kimi, Antigravity, pi) starting a session here must:**

1. Load the `swe-orchestrator` skill.
2. Read `docs/STATUS.md` and continue from "Next action".
3. Follow the gate protocol. Never continue past a pending gate (`docs/REVIEWS/`) without the owner's approval.
4. Update `docs/STATUS.md` after every meaningful step.

Project facts that are always true (stack, commands, conventions) go below once Architecture is approved.

## Commands
<!-- filled in by the orchestrator, e.g. install / dev / test / lint / eval / deploy -->

## Conventions
- Tests reference requirement IDs (e.g. `test_REQ_012_...` or `it("REQ-012: ...")`).
- Commits: `<type>(<scope>): <summary> [REQ-xxx]`.
- Secrets never go in git; use `.env` (gitignored) and keep `.env.example` current.
