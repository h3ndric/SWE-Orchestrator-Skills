# User guide: working with your AI engineering team

This guide is for the **owner**: the person with the idea. You don't need to know how to code.

## The deal

| You do | Your AI team does |
|---|---|
| Describe the idea and the end result you want | Research the market and similar products |
| Answer simple multiple-choice questions about *what* and *why* | Turn your answers into a precise, testable spec |
| Read 4 short briefs and say "approved" or comment | Pick the technology, design, build, test, secure and launch |
| Do the few things only a human can (accounts, payments, keys), using step-by-step instructions in `docs/OWNER-TODO.md` | Record every decision and explain it in plain words |

---

## 1. One-time setup on a new computer

Prerequisites: git, Node.js (for `npx`), and at least one of these agents installed and logged in: Claude Code, Copilot CLI, Kimi Code, Antigravity, pi, Cursor.

**Why install first?** An agent can only use skills that are already in its skills folder. Until they're installed, it doesn't know the orchestrator exists. You do this once per computer, not once per project.

**Easiest: let an agent install it.** Open any agent and paste:

> Install the skills from https://github.com/h3ndric/SWE-Orchestrator-Skills: clone it to ~/dev/SWE-Orchestrator-Skills and run its ./install.sh, then show me ./install.sh status.

That covers all 6 agents in one go. Plugin commands for installing into a single agent are in the README.

**Or from the terminal:**

```bash
git clone https://github.com/h3ndric/SWE-Orchestrator-Skills.git ~/dev/SWE-Orchestrator-Skills
cd ~/dev/SWE-Orchestrator-Skills
./install.sh            # installs into every agent it finds
./install.sh status     # each folder should show 12/12
```

If you use **Kimi**, also run this once inside Kimi: `/plugins install https://github.com/obra/superpowers`

If you use **Cursor**, also run this once in Cursor Agent chat: `/add-plugin superpowers`.

**On Windows**, agents installed on Windows itself (Claude Code, Copilot, Antigravity, Kimi, pi, Cursor) are covered either way:
- **You use WSL:** run `./install.sh` inside WSL as above. It also sets up the agents installed on Windows, and after updates `./install.sh update` refreshes them.
- **No WSL:** install [Git for Windows](https://git-scm.com/download/win) and [Node.js](https://nodejs.org), then in PowerShell run:

  ```powershell
  git clone https://github.com/h3ndric/SWE-Orchestrator-Skills.git $HOME\dev\SWE-Orchestrator-Skills
  cd $HOME\dev\SWE-Orchestrator-Skills
  powershell -ExecutionPolicy Bypass -File install.ps1          # status / update / uninstall also work
  ```

## 2. Start a new project

```bash
mkdir -p ~/dev/my-app && cd ~/dev/my-app
claude                  # or: copilot · kimi · agy · pi · cursor-agent (or open the folder in Cursor)
```

No setup step is needed. On its first run the orchestrator creates the project files by itself:
- `docs/` (status, spec, roadmap…)
- `AGENTS.md`, so any agent knows how to resume
- a git repository

If you open the agent in your home folder, it suggests a project folder for you.

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
- It also asks you to confirm two budgets: what you'll spend on AI agents while building, and the monthly running cost once live.
- It lists **every account or key it will need from you** for the whole project in `docs/OWNER-TODO.md`, so you can do them all in one sitting. It keeps building in the meantime.

**Keys and passwords never go in the chat.** Each task tells you exactly where to paste them (usually a file called `.env` in your project, or a settings page on the provider's site). If you paste one into the chat by accident, it will tell you to replace it with a new one.

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
| See what it needs from you | `what do you need from me?` (or read `docs/OWNER-TODO.md`) |
| Undo a milestone | `go back to how it was at gate 3`. It shows what would be lost and asks before doing anything |
| Note something the team should do better | `log a lesson: <what went wrong>` |

## 5. Which agent to use when

All 6 can run the whole thing. A practical split:
- **Claude Code:** Discovery, Architecture, reviews and gates, where reasoning quality matters most.
- **Kimi / Copilot / pi / Antigravity / Cursor:** long build milestones, if you want to spread cost or usage limits.

Because everything is in `docs/`, you can switch at any point.

## 6. Long projects and fresh sessions

One chat session can't hold a whole project, because AI agents have limited memory per session. The team handles this:
- It saves progress to `docs/` after every task.
- It hands heavy work to helper agents.
- It tells you when it's a good moment to start fresh.

When it says **"Good point to start a fresh session"**, or right after you approve a gate:
1. Start a new session (`/clear` in Claude Code, or close the agent and reopen it).
2. Say **continue**.

You lose nothing. It re-reads its notes and checks the code before carrying on.

## 7. Where to look in your project

| File | What it is |
|---|---|
| `docs/STATUS.md` | Where things stand and what's next |
| `docs/REVIEWS/` | Your gate briefs and your feedback |
| `docs/PRD.md` | The spec: what's being built |
| `docs/ROADMAP.md` | Milestones |
| `docs/MODULES.md` | **Module register:** every part of the system, its status, who's working on it, and test and review results |
| `docs/traceability.json` | Every requirement and whether it works yet |
| `docs/ARCHITECTURE.md`, `docs/adr/` | How it's built and why |
| `docs/LAUNCH.md`, `docs/RUNBOOK.md` | The go-live checklist and how to operate it |
| `docs/OWNER-TODO.md` | **Things only you can do**, with click-by-click steps |
| `docs/HARNESS-FEEDBACK.md` | Lessons about the team's own process, collected by the harness review (section 9) |

## 8. Keeping the skills up to date

```bash
cd ~/dev/SWE-Orchestrator-Skills
./install.sh update     # pulls the latest from GitHub and refreshes every agent
```

If you edit a skill yourself (e.g. your preferred technologies in `skills/swe-orchestrator/references/decision-policy.md`), the change is live in all agents immediately. Run `git commit` and `git push` to save it to GitHub.

## 9. Making the team better over time

The team improves itself from real mistakes, in three steps.

**1. Lessons are logged automatically.** In every project, the agent writes to `docs/HARNESS-FEEDBACK.md` whenever the *process* goes wrong: you correct it, it gets stuck, something it called done turns out broken, or a skill's instructions didn't fit. It also does a short look-back before every gate. You can add your own any time: say **`log a lesson: <what went wrong>`**. (Just tell it in the session too, so it corrects course right away.)

**2. A weekly review turns lessons into fixes.** It collects new lessons from all your projects, both folders on this computer and repos on GitHub. It groups repeated problems, drafts small fixes to the skills, and sends them to you for approval. It never changes the skills on its own.
- **If this repo is on GitHub:** you get a pull request notification. Open it, read the plain-language summary, and click **Merge** to accept. As the owner you can merge without a second reviewer. Or ask any agent: *"review harness feedback"* to go through it with you.
- **Without GitHub:** the fixes wait on a local branch with a report in `~/.swe-orchestrator/reports/`. The next time you start a project session, the agent mentions it. Open this repo in any agent and say *"review harness feedback"*.

Fixes go live in every agent and every project as soon as you accept them.

**3. Turn on the weekly schedule (once per computer):**

```bash
cd ~/dev/SWE-Orchestrator-Skills
scripts/harness-review.sh schedule     # Linux, macOS, WSL (on WSL it uses Windows Task Scheduler)
scripts/harness-review.sh status       # what it found, when it last ran
scripts/harness-review.sh run --now    # run a review right now
scripts/harness-review.sh unschedule   # turn it off
```

On Windows without WSL: `powershell -ExecutionPolicy Bypass -File scripts\harness-review.ps1 schedule` (same commands).

It checks every day but only starts an agent once a week, and only if there are new lessons, so it costs nothing in quiet weeks. If your computer was off, it catches up at the next check. It uses Claude Code if installed, otherwise pi or Copilot; set `SWE_REVIEW_AGENT=pi` to use your local model instead. It looks for projects in `~/dev` and in every project the orchestrator has worked on. Set `SWE_PROJECT_ROOTS` if you keep projects elsewhere.

## 10. Troubleshooting

| Problem | Fix |
|---|---|
| The agent doesn't use the orchestrator | Say explicitly: "Use the swe-orchestrator skill". Check `./install.sh status` |
| It asks you technical questions after Gate 1 | Reply "you decide, as the tech lead". That's its rule, and it'll comply |
| It seems stuck on the same problem | It's supposed to stop after 3 tries and change approach, then after 5 mark it blocked and move on. If it doesn't, say "you're stuck, step back and try another approach" |
| You don't like where a milestone went | Say "go back to gate N". Every approved gate is a saved restore point |
| It went past a gate without asking | Say "stop. Go back to gate N and write the brief." Then tell me so the skill can be tightened |
| Antigravity in `-p` (non-interactive) mode can't read files | Use it interactively, or add `--dangerously-skip-permissions` |
| You want to remove everything | `./install.sh uninstall` |
