# Dispatching roles as sub-agents

Sub-agents start with **no memory** of this conversation. Every dispatch prompt must be self-contained.

## Prompt template

```
You are the <ROLE> on a software project. Load and follow the skill `swe-<role>`
(if it is not available, follow the instructions below directly).

Project root: <absolute path>
Read first: docs/STATUS.md, docs/PRD.md<, docs/ARCHITECTURE.md, docs/plans/M<n>-*.md>

Task: <one clear, bounded task>
Scope: <files/dirs you may change; what you must NOT touch>
Requirements covered: <REQ-IDs>
Definition of done: <tests to pass / file to produce / checks to run>

Constraints:
- Do not ask the owner anything; if blocked, stop and report the blocker.
- Do not modify docs/STATUS.md (the orchestrator owns it).
- Never delete, skip or weaken a test, assertion, threshold or lint rule to get green.
- If the same failure persists after 3 attempts, stop and report what you tried.
- Commit your work with message "<type>(<scope>): <summary> [REQ-xxx]".

Report back (max 15 lines): what you did, files changed, test results (paste the
summary line), anything left undone or risky.
```

## What to parallelize

| Safe in parallel | Keep sequential |
|---|---|
| Researcher web searches on different topics | Interview (one owner, one question at a time) |
| Implementation tasks touching disjoint files | Tasks touching the same files or the DB schema |
| Reviewer + security review of the same diff | Merge → deploy |
| Writing tests for separate modules | Architecture decisions that depend on each other |

## Keep handoff chains short

Research found that tasks needing more than about 4 handoffs between agents usually fail, and that extra reviewer layers can *lower* success. Keep each chain to one or two hops: orchestrator → implementer → verifier/reviewer. Don't add more roles to a chain just because they exist. For a small milestone, the reviewer can do the security checklist in the same pass.

## Harness notes

- **Claude Code:** use the Agent/Task tool. Use `isolation: worktree` for parallel implementers.
- **GitHub Copilot CLI:** use its sub-agent / delegate feature if available. Otherwise run the tasks in sequence.
- **Kimi Code:** use agent profiles or sub-agents if available. Otherwise run in sequence.
- **Antigravity:** use its agent manager / parallel agents if available.
- **pi:** typically single-agent. Run roles in sequence by loading each role skill in turn.

Always verify sub-agent claims yourself: re-run the tests, and read the diff summary. Trust, but verify.
