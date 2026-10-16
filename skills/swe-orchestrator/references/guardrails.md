# Guardrails: enforce with machines, not prose

Instructions in Markdown are followed most of the time, not always. Anything that **must** hold has to be checked by a script that runs automatically. Git hooks and CI work the same in every agent (Claude, Copilot, Kimi, Antigravity, pi, Cursor), so they're the enforcement layer.

Principle: **scripts measure, agents judge.** Scripts give fast pass/fail. Agents interpret the results and fix things.

## Set up in M0 (walking skeleton)

| File | Purpose | Speed target |
|---|---|---|
| `scripts/init.sh` | Idempotent: install deps, prepare the env, start the app (dev server and DB), print the URL. Every session uses it, so no agent wastes time working out how to run the app. | < 1 min |
| `scripts/smoke.sh` | Fast end-to-end check of the core journey on the running app: an HTTP check plus one Playwright happy path once a UI exists. Exit non-zero on failure. | < 1 min |
| `scripts/check.sh` | Everything a commit must pass: format check, lint, type-check, unit tests, coverage threshold (`TST-04`), secret scan, SAST (semgrep), dependency audit (`SEC-11`, `SUP-03`). For UI, axe checks run in e2e (`A11Y-01`). | < 2 min |
| git `pre-commit` hook | Runs the fast parts of `check.sh`: format, lint, secret scan on staged files. Install it via a tool (`lefthook`, `husky`, or `pre-commit`) whose config is committed, so it survives fresh clones. | seconds |
| CI workflow | `check.sh`, the full test suite, the e2e suite, and the build. Merges to main require it to be green. | — |

Record these commands in the project `AGENTS.md` → Commands.

## Architecture boundaries as tests

The module register (`docs/MODULES.md`) says which module may depend on which. Turn that into a check:
- **TypeScript:** `dependency-cruiser` rules, or an ESLint `no-restricted-imports` rule.
- **Python:** `import-linter` contracts.

Write the error messages so they tell the agent how to fix the problem. For example: "web-ui must not import database directly; call the api module (MOD-02) instead." Fix messages written this way are how agents learn the rules on the spot.

## End-to-end verification, as a user would

Unit tests and `curl` miss real breakage. For every user-facing requirement:
- Write a **Playwright e2e test of the journey** (or the platform equivalent), with the REQ ID in its name.
- During verification, actually exercise the feature in a browser:
  - Use a browser tool if the harness has one, e.g. a Playwright or Chrome DevTools MCP.
  - Otherwise, run the e2e test headed or with screenshots, and look at them.
- After a check passes manually, turn it into a deterministic test so it's re-checked forever.

## Independent verification

The agent that built something must not be the one that marks it `pass`. The verifier is the reviewer, or a fresh-context verification sub-agent. It:
- re-runs the tests itself
- exercises the journey
- only then reports the item as passing, which lets the orchestrator set `status: "pass"` and `verified_by` in `docs/traceability.json`

## Parallel work isolation (when running several implementers)
- Give each one its own git worktree, its own port (e.g. `PORT=30xx`), and its own database or schema.
- A module claim in `docs/MODULES.md` must be held before starting. Never put two agents on one module.

## Turning failures into checks

When you see the same mistake twice (a wrong import, a missing validation, a forgotten migration, a leaked log of user data), don't add another sentence to a doc. Add a lint rule, a test, or a hook step, and note it in `docs/TECH-DEBT.md` → "Guardrails added".

## Doc gardening (during every increment review)

Docs drift from code, and stale docs mislead agents. Every 2–3 milestones, as part of the increment review, check these:
- Do `AGENTS.md` commands still work? Run them.
- Does `ARCHITECTURE.md` still match the code (components, stack, data model)?
- Do the rows in `MODULES.md` match the actual code folders?
- Is `AGENTS.md` still a short map (≤ ~100 lines) that points to docs, rather than a dumping ground?
- Are there TODO, FIXME or skipped tests? Log each one in `docs/TECH-DEBT.md` with its impact, and schedule the important ones into a milestone.

Fix what's cheap now. Put the rest in TECH-DEBT.
