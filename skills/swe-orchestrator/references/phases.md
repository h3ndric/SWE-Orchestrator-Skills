# Phase playbooks

Each phase lists its **inputs**, **steps**, **outputs** (files in `docs/`) and **exit criteria**.
Each phase also ends with a short **fallback** section. Use it when the role skill isn't installed.

---

## Phase 1: Discovery (research → interview → requirements spec)

**Goal:** know exactly what to build and why, precisely enough that "done" is testable.

1. **Research** (`swe-researcher`). This runs *before* the first question to the owner. Wait for the owner's initial idea message first, or ask for it in one line if it's empty.
   - Output: `docs/discovery/RESEARCH.md`, covering competitors and alternatives, user pain points, common features (table stakes vs differentiators), feasibility, AI options and rough costs.
2. **Interview** (`swe-business-analyst`). Ask one question at a time, multiple-choice with a recommendation, informed by the research.
   - Output: `docs/discovery/INTERVIEW.md`, a running Q&A log, plus a final "Here's what I heard" playback the owner confirms.
   - Stop only when the clarity checklist passes.
3. **Spec** (`swe-requirements-engineer`). Turn the interview into `docs/PRD.md`. It needs:
   - REQ IDs
   - user stories with Given/When/Then acceptance criteria
   - non-functional requirements (NFRs) and AI quality bars
   - out-of-scope items
   - the MVP vs full-vision split
   - Also create `docs/traceability.json`, with every REQ, NFR and AIQ at status `todo`.

**Exit:** the PRD passes the requirements engineer's quality check, and Gate 1 is approved.

**Fallback:**
- Do 5–10 web searches on similar products.
- Then interview the owner on these topics, one at a time:
  - goal and final state
  - users
  - top 3 problems
  - key user journeys
  - must/should/could/won't features
  - data and privacy
  - success metrics
  - budget and timeline
  - platforms
  - MVP vs full product
- Write the PRD using `templates/docs/PRD.md`.

---

## Phase 2: Architecture

**Goal:** the simplest design that satisfies every MVP requirement and doesn't block the full vision.

- `swe-architect` produces `docs/ARCHITECTURE.md`:
  - context and a component diagram (Mermaid)
  - tech stack with a why for each choice
  - data model
  - API surface
  - hosting and deployment target
  - security model
  - cost estimate (MVP monthly)
  - top risks with mitigations
  - how each NFR is met
- `swe-ai-engineer` adds an **AI design** section:
  - model choice and fallback
  - prompt management
  - RAG / tools / agents if needed
  - the eval plan: golden set + metrics + thresholds from the PRD's AI quality bars
  - guardrails
  - token cost and latency budget
- Write one ADR per significant decision in `docs/adr/NNNN-title.md`.
- List every owner task the design implies (accounts, keys, domains, payment, app stores) in `docs/OWNER-TODO.md`, each with a "needed by" milestone. See `references/owner-tasks.md`.
- Propose the build and running budgets for the owner to confirm (`references/stuck-and-budget.md` §5).

**Exit:** every MVP REQ maps to a component, and Gate 2 is approved.

**Fallback:**
- Pick a mainstream stack, for example:
  - TypeScript + Next.js + Postgres (Supabase/Neon), deployed to Vercel/Fly
  - or Python + FastAPI + Postgres
  - Claude API for the AI.
- Document it with the template.

---

## Phase 3: Roadmap

- Split the MVP into **milestones of roughly 1–3 days of agent work**. Each milestone must:
  - produce something demo-able
  - list its REQ IDs
  - have its own acceptance checks
- Milestone 0 is always the **walking skeleton**: the repo, tooling, lint/format, test runner, a "hello world" deployed end to end, and a CI pipeline running tests. It also sets up the guardrails in `references/guardrails.md`: `scripts/init.sh`, `smoke.sh`, `check.sh`, a pre-commit hook with secret scanning, and boundary checks.
- Put full-vision items in later milestones, marked "post-MVP".
- Output: `docs/ROADMAP.md` and `docs/MODULES.md`. The register has one row per component from the architecture, with milestone, REQs and dependencies filled in, and every status ⬜.
- There's no gate here; go straight to the build loop.

---

## Phase 4: Build loop (repeat per milestone)

For milestone M:

1. **Plan:** write `docs/plans/M<n>-<slug>.md`. Make it a bite-sized task list where each task has:
   - the files involved
   - the test to write first
   - the verification command
   - Use superpowers `writing-plans` if available.
   - Record the plan's size (task count and expected sessions) in STATUS → Budget.
2. **Branch:** tag `m<n>-start` on main, then create `m<n>-<slug>`. Use superpowers `using-git-worktrees` if available.
3. **Implement** (`swe-implementer`): TDD per task (red → green → refactor), commit per task.
   - Run independent tasks in parallel sub-agents if your harness supports it. Use superpowers `subagent-driven-development` if available.
   - Test names reference REQ IDs.
4. **Review** (`swe-reviewer`): check correctness, the spec match against the REQ acceptance criteria, simplicity and test quality. Fix all critical and important findings.
5. **Security** (`swe-security`): run the per-milestone checklist (secrets, input validation, authz, dependencies, prompt injection for AI features). Fix the findings.
6. **Verify:**
   - Run the full test suite, lint and type-check.
   - Actually run the app and exercise the milestone's user journey in a browser, as a user would. Add or extend the Playwright e2e test for it.
   - Verification is done by the reviewer or a fresh-context verifier, **not the implementer**. Only then set items to `pass` in `docs/traceability.json`.
   - Run AI evals if the milestone touched AI.
   - **Spec-coverage check** before the Gate 3 brief. A diff review can't see what was never written. Dispatch one fresh-context, read-only child per requirement group, with one question: "for each acceptance criterion, name the test whose assertions prove it, or say none." It judges assertions, not test names, and runs nothing. A criterion is `UNMET` until a named test asserts it.
   - Update `docs/traceability.json`.
7. **Register:** update `docs/MODULES.md`:
   - status, test counts and the reviewed/security dates for each module touched
   - clear the claims
   - log any interface changes
   
   Every 2–3 milestones, run the increment review (see SKILL.md → Module register).
8. **Merge:** merge to main and make sure CI is green. Use superpowers `finishing-a-development-branch` if available.
9. **Gate 3:** write the milestone demo brief and stop.

**Debugging:** use superpowers `systematic-debugging` if available. Otherwise:
- reproduce → isolate → form a hypothesis → test it → fix → add a regression test
- never guess-and-check more than twice without re-reading the evidence
- after 3 failed fix attempts on the same issue, step back and question the design, then write an ADR if it changes.
- after 5, mark it blocked and move on. Full rules: `references/stuck-and-budget.md`.

---

## Phase 5: Production readiness

`swe-release-sre` (+ `swe-security` full audit, + `swe-ai-engineer` eval run) produces `docs/LAUNCH.md`:

- CI/CD: tests, lint and build on every push; deploy on main; preview environments if cheap.
- Environments and secrets: no secrets in the repo, use an env var / secret manager, and keep a `.env.example`.
- Auth and authz verified, rate limiting, input limits.
- Data: backups enabled and a restore tested; migrations are versioned.
- Observability: structured logs, error tracking, uptime check, and an alert to the owner's email. For AI features, also LLM tracing plus cost and latency dashboards.
- AI: the eval suite passes its thresholds, a cost cap or budget alert, and documented fallback behavior for when the model fails.
- Performance sanity check against the NFRs.
- Rollback plan + runbook: how to deploy, roll back, rotate a key, and what to do if it's down.
- Legal basics as flagged in the PRD: privacy policy, terms, data deletion.
- `docs/traceability.json`: every MVP item is `pass`.

**Exit:** Gate 4 is approved. Then deploy to production, verify it in production, and update STATUS to "Live".

---

## Phase 6: Operate / iterate

- New owner requests become **change requests** (see gates.md). The business analyst clarifies them, the requirements engineer updates the PRD with new REQ IDs and a changelog entry, and the architect updates the roadmap. Then the build loop resumes.
- Full-vision milestones continue the same way, with Gate 3 for each one.
