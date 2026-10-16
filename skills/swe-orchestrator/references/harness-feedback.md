# Harness feedback: logging lessons about the team itself

The harness (these skills) improves by reacting to real failures. You are the one who sees them, so you log them in the project's `docs/HARNESS-FEEDBACK.md`. A scheduled review (the `swe-harness-review` skill) later collects entries from every project, fixes the skills, and sends the fixes to the owner as a pull request (or a local report).

This file is about **the process, not the product**. A product bug goes in the normal backlog. A lesson goes here when a skill made you, or let you, do the wrong thing.

## When to log (do it right away, without asking)

| Trigger | Example |
|---|---|
| `owner-correction` | The owner corrected your behavior: "don't ask me that", "you skipped X", "that's not what I said" |
| `gate-rework` | The owner chose "Approve with changes" or "Rethink" at a gate, and the cause was process, not a change of mind |
| `stuck` | You hit the 3- or 5-attempt limit, or a milestone reached 2× its planned size |
| `false-done` | Something marked done or `pass` turned out broken (smoke failed at session start, a reviewer found it not working) |
| `skill-gap` | A skill's instructions were unclear, contradictory, missing a case, or wasted effort |
| `tool-gap` | A step assumed a tool this agent doesn't have (sub-agents, browser, a structured question tool), or a command failed on this OS |
| `retro` | Something from the gate retro below |
| `owner-note` | The owner said "log a lesson: …". Write their words down faithfully |

Don't log: the owner simply changing their mind, normal test failures fixed on the first or second try, or problems in third-party tools that no skill change could avoid.

## How to log

Append one entry per lesson to `docs/HARNESS-FEEDBACK.md`. Use the next `HF-` number, and never edit or delete earlier entries:

```markdown
### HF-004 · 2026-10-16 · pi (qwen38-nvfp4) · Build M2
- **Trigger:** false-done
- **What happened:** Marked REQ-012 pass after unit tests only; the page never loaded in a browser.
- **Expected:** guardrails.md says user-facing REQs need a Playwright run before pass.
- **Suggested fix:** Make "pass" for user-facing REQs require a recorded e2e run in traceability.json (check in scripts/check.sh).
- **Severity:** high
```

Keep it short and factual. Name the agent and model you are running as. Commit it with your other changes. **No secrets, keys or personal data**: the review may publish a generalized version of the lesson.

## Gate retro (every gate, 2 minutes)

Before writing a gate brief, look back over the work since the last gate and ask:
1. Where did I go in circles, redo work, or get corrected?
2. Did any instruction get in the way, or was something missing that I had to improvise?
3. Did anything I said was done turn out not to be?

Log each real lesson as a `retro` entry. If there's nothing, log nothing. Don't pad. Never put the retro in the gate brief: the owner reviews the product there, and harness lessons go to the harness review.

## Project registry

So the scheduled review can find this project (even if it never goes to GitHub), make sure it is listed in the registry at session start:
- File: `~/.swe-orchestrator/projects.tsv` (on Windows: `%USERPROFILE%\.swe-orchestrator\projects.tsv`).
- One line per project: `<absolute path><TAB><git remote URL or -><TAB><date first seen>`.
- Add the line if the path isn't there yet. If the remote changed (the project was pushed to GitHub), update that line. Create the folder and file if missing.

## Pending harness review

If `~/.swe-orchestrator/reports/` contains a report whose first line reads `Status: waiting for owner`, a harness review is waiting for the owner and there is no GitHub pull request to notify them. Tell them in one line at session start: "A harness improvement review is waiting: <path>. Say *review harness feedback* in the harness repo to go through it."
