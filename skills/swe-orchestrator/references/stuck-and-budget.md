# Stuck detection and budget: stop loops before they burn time and money

An agent left alone can retry the same failing fix for hours, quietly weaken a test until it "passes", or keep expanding a milestone. The owner can't see this happening. These limits make it visible and stop it.

## 1. The attempt limit (per failure)

Count attempts **per distinct failure**: the same failing test, the same error message, the same broken build step.

| Attempts on the same failure | What to do |
|---|---|
| 1–3 | Normal fixing. Read the error properly; don't guess. |
| After 3 | **Stop patching.** Switch to root-cause mode: use `superpowers:systematic-debugging` if installed, otherwise reproduce minimally, form one hypothesis, test it. Consider a **different approach** (another library, a simpler design, cutting the feature to its core). Write an ADR if the design changes. |
| After 5 total | **Mark it blocked.** Revert to the last green commit (or leave the work on a branch), log it in STATUS under "Blockers" with what was tried, and move to the next independent task. Raise it at the next gate, or right away if nothing else can proceed. |

Sub-agents follow the same rule: after 3 failed attempts on the same failure, they stop and report back instead of continuing. You decide the next step.

## 2. Loop signals (stop and reassess when you see any)

- The same command run 3+ times with the same error.
- The same file edited back and forth (a change undone and redone).
- No passing commit for a long stretch of work (roughly: more than one plan task's worth).
- A plan task has grown to more than twice its planned size.
- You're about to "fix" a test rather than the code.

## 3. Never cheat to get green

These are never allowed to make a check pass. They count as a failure, not a fix:
- deleting, skipping (`.skip`, `xit`, `@pytest.mark.skip`) or commenting out a test
- weakening an assertion, or changing expected values to match wrong output
- lowering coverage thresholds, disabling lint rules or loosening type checks
- catching and swallowing an error to hide it
- editing acceptance criteria in `docs/PRD.md` or `docs/traceability.json`

If a test is truly wrong (it contradicts the PRD), fix the test **and** say so explicitly in the commit message and the milestone report, citing the REQ. The reviewer checks for this.

## 4. Milestone budget

- When planning a milestone, record its size in the plan: number of tasks, and an expected number of sessions.
- Track actual sessions in `docs/STATUS.md` → Budget.
- **If a milestone reaches 2× its expected sessions or tasks:** stop adding scope. Run a mini increment review: what's taking longer, and why? Then either cut scope (move REQs to a later milestone) or tell the owner at the next gate, with the reason and a new estimate.

## 5. Spending (agent usage and cloud costs)

- **At Gate 2**, ask the owner for two budgets, in plain words:
  - **Build budget:** what they're willing to spend on AI agent usage while building (e.g. "up to $X per month, or stay within my subscription"). Many agents run on a subscription with usage limits, so this may simply be "stay within the plan".
  - **Running budget:** the monthly ceiling for hosting, database and AI APIs once live.
- Record both in `docs/STATUS.md` → Budget.
- Agents often can't see their own token spend. Use what you can measure (sessions per milestone, subagent dispatches, eval runs) and prefer cheap patterns: thin coordinator, focused sub-agent prompts, small eval sets during development, the full eval set only at milestone end.
- **Cloud and API spend:** every paid service gets a spending limit or budget alert at setup (an owner task, see [owner-tasks.md](owner-tasks.md)). Never pick an option that can bill without a ceiling without saying so in the gate brief.
- Anything likely to exceed either budget is a gate decision for the owner, not a silent choice.
