# Harness log: improving the team itself

Best practice says to build a harness **in reaction to observed failures**, and to test it like code. Agents log lessons in each project's `docs/HARNESS-FEEDBACK.md`; the `swe-harness-review` skill (scheduled weekly by `scripts/harness-review.sh`) collects them, records each fix here, and sends it to the owner for approval. You can also add rows by hand.

**This repo is public:** rows describe the harness failure in general terms. No project names, product details, code or personal data (refer to "Project A").

| Date | Agent | Project / phase | What went wrong | Fix (skill edit / new check) | Commit |
|------|-------|-----------------|-----------------|------------------------------|--------|

## Planned: harness evals
- Freeze 20–50 small tasks drawn from real failures recorded above. Each one needs a known-good outcome, e.g. "stops at Gate 1", "never asks a technical question after Gate 1", "doesn't mark pass without independent verification".
- Keep the model fixed and change one skill at a time, then compare before and after. Use `claude plugin eval` where available.
- Give each rule an expiry: if a newer model no longer needs a rule, remove it, because stale rules cost context.
