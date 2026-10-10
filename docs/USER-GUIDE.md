# User guide: working with your AI engineering team

This guide is for the **owner**: the person with the idea. You don't need to know how to code.

## The deal

| You do | Your AI team does |
|---|---|
| Describe the idea and the end result you want | Research the market and similar products |
| Answer simple multiple-choice questions about *what* and *why* | Turn your answers into a precise, testable spec |
| Read 4 short briefs and say "approved" or comment | Pick the technology, design, build, test, secure and launch |
| Create accounts or paste keys when asked (rare) | Record every decision and explain it in plain words |

---

## 1. One-time setup on a new computer

Prerequisites: git, Node.js (for `npx`), and at least one of these agents installed and logged in: Claude Code, Copilot CLI, Kimi Code, Antigravity, pi.

```bash
git clone https://github.com/h3ndric/SWE-Orchestrator-Skills.git ~/dev/SWE-Orchestrator-Skills
cd ~/dev/SWE-Orchestrator-Skills
./install.sh            # installs into every agent it finds
./install.sh status     # each folder should show 10/10
```

If you use **Kimi**, also run this once inside Kimi: `/plugins install https://github.com/obra/superpowers`

## 2. Start a new project

```bash
~/dev/SWE-Orchestrator-Skills/install.sh init ~/dev/my-app
cd ~/dev/my-app
claude                  # or: copilot · kimi · agy · pi
```

Type your idea. Be as rough as you like. For example:

> /swe-orchestrator I want an app where small shop owners upload receipts and an AI tracks their expenses and warns them about cash-flow problems. MVP first, then a full product later.

(In agents without slash commands, just write "Use the swe-orchestrator skill. I want to build…".)

## 3. What happens, and what you do at each step

### Step 1: Research (about 5–15 min, nothing for you to do)
It studies similar products, what their users complain about, and what's technically possible and what it costs. It saves this in `docs/discovery/RESEARCH.md`. Read it if you're curious.

### Step 2: The interview (about 15–40 min, this is your main job)
It asks one question at a time, usually with options like:

> **Should people need an account to use it?**
> A) Yes, sign in with Google *(recommended: competitors X and Y do this, and it lets us save their history)*
> B) Yes, email and password
> C) No account, everything stays on their device
> D) Something else

Tips:
- **"You decide"** is always a fine answer. It picks the recommendation and notes it as an assumption, which you'll see at Gate 1.
- Give **real examples** when it asks what good AI output looks like. They become the tests the AI must pass.
- You can stop anytime. Just come back and say "continue".

It finishes with **"Here's what I heard…"**. Correct anything that's wrong.

### ★ Gate 1: Requirements sign-off
It writes `docs/PRD.md` (the full spec) and `docs/REVIEWS/gate-1.md` (a one-page summary), then **stops**.
- Check: is this the product I want? Is the MVP the right size? Is anything missing, or anything included that shouldn't be?
- Reply **"approved"** or with comments, e.g. *"Drop the team feature from MVP; add CSV export."*

### Step 3: Architecture (automatic)

### ★ Gate 2: Architecture brief
A picture of the system, the technology choices (each with a one-line plain reason), the **monthly cost estimate**, risks, and the milestone plan.
- Check: is the cost OK? Are the risks acceptable? Does the milestone order make sense to you?
- You can override any decision, e.g. *"I already have an AWS account, use that."*

### Step 4: Building (automatic, milestone by milestone)
For each milestone, the team plans, writes tests first, builds, reviews the code, checks security and verifies, all by itself. The first milestone is always a tiny version that's actually online, which proves deployment works.

### ★ Gate 3: Milestone demo (once per milestone)
It tells you **how to try it** (a link or exact steps), shows which requirements now work and pass their tests, and lists any known issues.
- **Try it yourself.** This is the most valuable review you can do.
- Comment in plain language, e.g. *"The summary is too long; I want 3 bullet points"* or *"The button should say Save, not Submit."*

### ★ Gate 4: Go-live
The launch checklist covers:
- every MVP requirement passing
- security audited
- backups tested
- monitoring that emails you if it breaks
- a rollback plan
- AI quality tests passing
- the running cost
- It also lists anything only you can do, such as buying a domain, adding a payment method, or creating a production account.
- Reply **"approved"** and it deploys, checks the live site, and marks the project **Live**.

### After launch
Ask for changes anytime: *"Add a weekly email report."* It treats this as a **change request**: it asks 1–3 questions, updates the spec, plans a milestone, and you get a Gate 3 demo when it's done.

---

## 4. Everyday commands

| You want to… | Say |
|---|---|
| Pick up where you left off | `continue` |
| Know where things stand | `status?` (or read `docs/STATUS.md`) |
| Approve a gate | `approved` |
| Change something | Plain words: "I'd rather…", "Remove…", "Add…" |
| Pause | Just close the agent. Everything is saved in `docs/` |
| Switch to a different agent | Open the project in it and say `continue` |

## 5. Which agent to use when

All 5 can run the whole thing. A practical split:
- **Claude Code:** Discovery, Architecture, reviews and gates, where reasoning quality matters most.
- **Kimi / Copilot / pi / Antigravity:** long build milestones, if you want to spread cost or usage limits.

Because everything is in `docs/`, you can switch at any point.

## 6. Where to look in your project

| File | What it is |
|---|---|
| `docs/STATUS.md` | Where things stand and what's next |
| `docs/REVIEWS/` | Your gate briefs and your feedback |
| `docs/PRD.md` | The spec: what's being built |
| `docs/ROADMAP.md` | Milestones |
| `docs/TRACEABILITY.md` | Every requirement and whether it works yet |
| `docs/ARCHITECTURE.md`, `docs/adr/` | How it's built and why |
| `docs/LAUNCH.md`, `docs/RUNBOOK.md` | The go-live checklist and how to operate it |

## 7. Keeping the skills up to date

```bash
cd ~/dev/SWE-Orchestrator-Skills
./install.sh update     # pulls the latest from GitHub and refreshes every agent
```

If you edit a skill yourself (e.g. your preferred technologies in `skills/swe-orchestrator/references/decision-policy.md`), the change is live in all agents immediately. Run `git commit` and `git push` to save it to GitHub.

## 8. Troubleshooting

| Problem | Fix |
|---|---|
| The agent doesn't use the orchestrator | Say explicitly: "Use the swe-orchestrator skill". Check `./install.sh status` |
| It asks you technical questions after Gate 1 | Reply "you decide, as the tech lead". That's its rule, and it'll comply |
| It went past a gate without asking | Say "stop. Go back to gate N and write the brief." Then tell me so the skill can be tightened |
| Antigravity in `-p` (non-interactive) mode can't read files | Use it interactively, or add `--dangerously-skip-permissions` |
| You want to remove everything | `./install.sh uninstall` |
