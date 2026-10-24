# Dispatching roles as sub-agents

Sub-agents start with **no memory** of this conversation. Every dispatch prompt must be self-contained.

## Prompt template

```
You are the <ROLE> on a software project. Load and follow the skill `swe-<role>`
(if it is not available, follow the instructions below directly).

Project root: <absolute path>
Read first: docs/STATUS.md, docs/PRD.md<, docs/ARCHITECTURE.md, docs/plans/M<n>-*.md>

Task: <one clear, bounded task: about one file plus its tests>
Scope: <files/dirs you may change; what you must NOT touch>
Requirements covered: <REQ-IDs>
Definition of done: <tests to pass / file to produce / checks to run, and how long each check takes>

Constraints:
- Do not ask the owner anything; if blocked, stop and report the blocker.
- Do not modify docs/STATUS.md (the orchestrator owns it).
- Never delete, skip or weaken a test, assertion, threshold or lint rule to get green.
- If the same failure persists after 3 attempts, stop and report what you tried.
- Make your first file write within your first ~8 tool calls; read more only as you need it.
- Commit the failing test before you run new tests, then commit the code, so a timeout
  leaves a checkpoint. A failing command is something to fix, not a reason to stop.
- Commit your work with message "<type>(<scope>): <summary> [REQ-xxx]".

Report back (max 15 lines): what you did, files changed, test results (paste the
summary line), anything left undone or risky.
```

**Size the brief, not the clock.** Children given a whole milestone task explore until they time out and leave nothing behind. Give one child one part: about one file plus its tests. Split bigger work into at most 3 numbered children, each ending in its own commit. If a check takes minutes, say how long, so the child runs it while it still has time.

## Review and security children: pin the scope

A review child told to "review this diff" wanders the repo and can time out; one given a short, pinned list finishes. Scope is the reliability knob, not the time limit. For every reviewer or security dispatch, add to the template:
- **One question:** put the one question that could change the merge decision in the first line, alongside the standing checklist. If a second question matters, use a second child.
- **Files:** an explicit list of at most ~10 files. Split a bigger review into several children.
- **What not to do:** read-only commands only, at most 2 commands after the files are read, no file writes, and no experiments to prove a library's documented behavior. Reasoning from the source and existing tests is enough; state uncertainty instead of proving it.
- **Spec:** paste the relevant REQ criteria and plan extract into the prompt. "Don't go looking for other files."
- **Tests:** say whether to run the suite. If the suite already ran on this commit (CI or a verification child), paste its summary line and say "do not re-run it".
- **Answer cap:** findings only, at most ~40 lines.
- **Where the report goes:** if the child can write files, give the path. If it is read-only, say "return the report in your reply; the orchestrator will write it to `<path>`". Then the review record says the child's report is reproduced and the dispositions are yours.

Tell the child: "If you run short of budget, report a partial verdict rather than nothing." If a child times out, retry once with a narrower scope. If it still fails, record the timeout in the review record. Never mark the module reviewed without a report.

## While children run

- **A background child dies with its session.** Don't end a session while one is running. In STATUS, phrase the next action as "run X; done when `<file>` exists", never "running as sub-agents". A claim in MODULES.md with no output file and no commits is stale: re-dispatch it.
- **While a child shares your working tree, never use `git commit -a`.** Commit only the paths you changed (`git commit <paths>`), or give the child its own worktree.

## Reading a child's results

- **A child's findings exist only once you have read them**, from the file it wrote or the tool result it returned. Before you repeat, summarize or act on a delegated finding, name that file or tool result. If you can't, you haven't read it.
- Async children often return only a stub at first. While a child is still running, say so and do work you can verify. Never narrate what its report "will say", and never write such numbers or claims into code, comments or docs.
- Check that every file a finding cites exists in this repo. A finding about a file or feature that isn't here was pattern-matched from somewhere else: drop it, or log it as "outside this codebase".

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
- **Cursor:** use its sub-agents if available. Otherwise run in sequence.
- **pi:** typically single-agent. Run roles in sequence by loading each role skill in turn.

Always verify sub-agent claims yourself: re-run the tests, and read the diff summary. Trust, but verify.
