# Harness log: improving the team itself

Best practice says to build a harness **in reaction to observed failures**, and to test it like code. Agents log lessons in each project's `docs/HARNESS-FEEDBACK.md`; the `swe-harness-review` skill (scheduled weekly by `scripts/harness-review.sh`) collects them, records each fix here, and sends it to the owner for approval. You can also add rows by hand.

**This repo is public:** rows describe the harness failure in general terms. No project names, product details, code or personal data (refer to "Project A").

| Date | Agent | Project / phase | What went wrong | Fix (skill edit / new check) | Commit |
|------|-------|-----------------|-----------------|------------------------------|--------|
| 2026-10-17 | orchestrator (pi) | Project A / M1 review | Summarized async review children's findings before they had written anything; an invented number reached a committed code comment | `subagents.md` → "Reading a child's results": name the file or tool result before repeating a finding; say "still running" instead of narrating; one-line pointer in `swe-orchestrator` context management | (this branch) |
| 2026-10-17 | orchestrator (pi) | Project A / M1 review | A review child given an open-ended "review this diff" timed out repeatedly (third time); a child with pinned files finished. A read-only child silently couldn't write its report file | `subagents.md` → "Review and security children: pin the scope": ≤~10 files, spec inline, test instruction, answer cap, explicit report destination for read-only children, timeout handling; `swe-reviewer` pass 0 accepts a pasted suite result for the same commit | (this branch) |
| 2026-10-17 | reviewer child | Project A / M1 review | Reported an important finding citing a plan file and feature that don't exist in the repo | `swe-reviewer` rule: open each cited file before reporting; drop or label "outside this codebase"; same check in `subagents.md` for the orchestrator | (this branch) |
| 2026-10-17 | orchestrator (pi) | Project A / M1 review | Two file writes to a review record reported success but the file on disk was unchanged; found only when a later edit failed | `guardrails.md` → "Verify your own writes": `git diff --stat <path>` before building on a write; never stack an edit on an unverified write | (this branch) |

## Planned: harness evals
- Freeze 20–50 small tasks drawn from real failures recorded above. Each one needs a known-good outcome, e.g. "stops at Gate 1", "never asks a technical question after Gate 1", "doesn't mark pass without independent verification".
- Keep the model fixed and change one skill at a time, then compare before and after. Use `claude plugin eval` where available.
- Give each rule an expiry: if a newer model no longer needs a rule, remove it, because stale rules cost context.
