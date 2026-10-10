# Gate protocol

The owner is not technical. A gate brief must be readable in **under 3 minutes**, and they must be able to answer it with "approved" or with plain-language comments.

## Rules

- File: `docs/REVIEWS/gate-<N>[-m<k>].md`, for example `gate-1.md`, `gate-2.md`, `gate-3-m2.md`, `gate-4.md`.
- In chat: a 5–10 line summary plus the file path. Then **stop**. Do not start the next phase in the same turn.
- Lead with what the owner cares about: what it does for users, what it costs, what's risky, and what you need from them.
- Put technical detail in the linked docs, not in the brief.
- Always end with the exact options: **Approve** / **Approve with changes (list them)** / **Rethink (say what's wrong)**.

## Brief template

```markdown
# Gate <N>: <name>: <project>
Date: <YYYY-MM-DD> · Status: ⏳ Waiting for owner

## In one paragraph
<what this gate is about and the headline>

## What you're approving
- <3–7 bullets in plain language>

## What it means for you
- Cost: <$/month estimate, one-time costs>
- Time: <next milestones, rough effort>
- Risks: <top 1–3, plain language, with what we'll do about each>

## Decisions I made for you (you can override any)
| Decision | What I chose | Why, in plain words |
|---|---|---|

## Things only you can do (if any)
- <open tasks from docs/OWNER-TODO.md, earliest "needed by" first, one line each, e.g. "Create a free Supabase account (5 min, needed by M2): see task 1 in docs/OWNER-TODO.md">

## Details (optional reading)
- <links to PRD / ARCHITECTURE / ADRs / test report>

## Owner feedback
<!-- Write "approved" or your comments here, or reply in chat -->
```

## Gate-specific content

- **Gate 1: Requirements sign-off.** Include:
  - the vision in 2 sentences
  - personas
  - MVP features (must-haves) vs later
  - what's explicitly out of scope
  - success metrics
  - AI quality bar ("it should get roughly X out of 10 of these right")
  - the questions that are still assumptions
- **Gate 2: Architecture brief.** Include:
  - a picture (Mermaid diagram)
  - the stack, each item with a one-line plain reason
  - where it runs
  - monthly cost estimate (low / expected / high usage)
  - which AI model and why
  - **the rigor profile** (P1/P2/P3), in plain words. For example: "Production level: real users and personal data, so full security baseline, backups and accessibility"
  - top risks
  - the roadmap preview (milestone list)
  - **all owner tasks for the whole project** in `docs/OWNER-TODO.md`, each with a "needed by" milestone, including a private GitHub repository for off-machine backup
  - **two budgets to confirm:** build budget (AI agent usage) and running budget (monthly hosting, database and AI APIs). See [stuck-and-budget.md](stuck-and-budget.md) §5
- **Gate 3: Milestone demo.** Include the module "Health at a glance" block from `docs/MODULES.md`. Every 2–3 milestones, also include the increment review result and any proposed roadmap change. Also include:
  - what you can try now, with exact steps or a URL
  - a screenshot or terminal output if possible
  - a REQ table (REQ → built? → test passing?)
  - test, eval and security summary
  - known issues, including anything marked blocked after the attempt limit
  - budget: sessions used versus planned for this milestone, if it ran over
  - the next milestone
- **Gate 4: Go-live.** Include:
  - the launch checklist from `docs/LAUNCH.md`, every line ✅ or explained
  - the release Definition of Done from `swe-standards` §3, met, plus any waived rules with their ADRs
  - final REQ coverage (all MVP ✅)
  - running cost
  - what monitoring will alert them about
  - how to roll back
  - what you need them to do (domain, payment, accounts)

## Processing owner feedback (change requests)

1. Copy the feedback verbatim into the gate file under "Owner feedback" if they replied in chat.
2. Classify each comment:
   - **clarification:** answer it, no change needed
   - **change to scope or requirements:** load `swe-business-analyst` to clarify if needed (ask at most 1–3 focused questions), then have `swe-requirements-engineer` update the PRD with new or changed REQ IDs and a changelog entry
   - **change to design:** update ARCHITECTURE and write an ADR
   - **bug or quality issue:** add it to the current or next milestone plan
3. Re-plan the affected roadmap milestones.
4. If the change is large, re-issue the same gate with a short "What changed" section at the top. If it's small, note it in STATUS and continue.
5. Once approved: mark the gate file status `✅ Approved <date> · tag gate-<N>[-m<k>]-approved`, commit, create that tag, and push with tags if there's a remote. See [checkpoints-and-undo.md](checkpoints-and-undo.md).
6. If the feedback is "undo" or "go back", follow [checkpoints-and-undo.md](checkpoints-and-undo.md) §2.
