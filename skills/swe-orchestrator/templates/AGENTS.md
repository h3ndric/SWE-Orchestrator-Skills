# Agent instructions

This project is run by the **swe-orchestrator** skill: an autonomous tech lead working for a non-technical owner.

**Any agent (Claude Code, Copilot, Kimi, Antigravity, pi, Cursor) starting a session here must:**

1. Load the `swe-orchestrator` skill.
2. Read `docs/STATUS.md` and `docs/MODULES.md`, then continue from "Next action". Don't work on a module someone else has claimed.
3. Follow the gate protocol. Never continue past a pending gate (`docs/REVIEWS/`) without the owner's approval.
4. Update `docs/STATUS.md` and `docs/MODULES.md` after every meaningful step.
5. Log lessons about the process itself (corrections, stuck loops, false "done", unclear skill instructions) in `docs/HARNESS-FEEDBACK.md`. When the owner says "log a lesson: …", add it there.

Project facts that are always true (stack, commands, conventions) go below once Architecture is approved.

## Commands
<!-- filled in by the orchestrator, e.g. install / dev / test / lint / eval / deploy -->

## Conventions
- Tests reference requirement IDs (e.g. `test_REQ_012_...` or `it("REQ-012: ...")`).
- Commits: `<type>(<scope>): <summary> [REQ-xxx]`.
- Secrets never go in git or chat; use `.env` (gitignored) and keep `.env.example` current.
- Never delete, skip or weaken a test, threshold or lint rule to make a check pass. After 3 failed attempts on the same failure, stop and change approach or report it.
