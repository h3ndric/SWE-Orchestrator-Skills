# Module register

Owned by the **orchestrator** (tech lead). Created by the architect after Gate 2, and updated by the orchestrator after every build task, review and security pass. Sub-agents report changes; they don't edit this file.

Last updated: <YYYY-MM-DD> by <agent>

## Health at a glance
- Modules: <n> total · ✅ <n> done · 🟡 <n> in progress · 🔍 <n> in review · ⬜ <n> planned · ⛔ <n> blocked · ⚠️ <n> with issues
- MVP modules done: <n>/<n>
- Top concern: <one line, or "none">

## Register

Status legend:
- ⬜ planned
- 🟡 in progress
- 🔍 in review
- ✅ done (built, tests passing, reviewed, security-checked)
- ⚠️ done with known issues
- ⛔ blocked

| ID | Module | What it does (plain) | Status | Claimed by | Milestone | REQs | Depends on | Tests (pass/total) | Reviewed | Security | Notes / risks |
|----|--------|----------------------|--------|------------|-----------|------|------------|--------------------|----------|----------|---------------|
| MOD-01 | web-ui | Screens people use | ⬜ | — | M1 | REQ-001 | MOD-02 | 0/0 | — | — | |
| MOD-02 | api | Handles requests, rules | ⬜ | — | M1 | REQ-001 | MOD-03 | 0/0 | — | — | |
| MOD-03 | database | Stores data | ⬜ | — | M0 | NFR-003 | — | 0/0 | — | — | |

Columns:
- **Claimed by:** the agent and role currently working on the module, e.g. `kimi/implementer`, or `—`. Only one claim per module at a time.
- **Reviewed / Security:** the date of the last pass, or `—`.
- **Interfaces:** see `docs/ARCHITECTURE.md` §6. List a module's public functions or endpoints there, not here.

## Interface changes log
Record any change to how one module talks to another. Dependent modules must be re-checked.

| Date | Module | Change | Affected modules | Re-verified? |
|------|--------|--------|------------------|--------------|

## Increment reviews (every 2–3 milestones)
| Date | After milestone | Risks that grew | Estimate accuracy | Roadmap change | MVP re-cut? |
|------|-----------------|-----------------|-------------------|----------------|-------------|
