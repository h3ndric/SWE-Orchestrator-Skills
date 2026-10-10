# Owner tasks: things only the owner can do

Some steps need a human: creating accounts, entering payment details, accepting terms, buying a domain, getting API keys, verifying an identity, submitting to an app store. Non-engineer owners stall here more than anywhere else, so treat these tasks as a deliverable you design carefully, not an afterthought.

All of them live in `docs/OWNER-TODO.md` (template). It's the single list the owner checks. Gate briefs link to it instead of repeating it.

## 1. Find them early, batch them, don't block on them

- **At Gate 2**, list every owner task the architecture implies for the whole project, e.g. hosting account, database account, LLM provider key, domain, email sender, payment provider, Apple/Google developer accounts. Mark each with **needed by** (a milestone) so the owner can do them in one sitting, ahead of time.
- **Never sit idle waiting.** Until a key arrives, keep building against a fake or local stand-in:
  - an interface with a fake implementation
  - local Postgres or SQLite
  - a mock LLM client
  
  Only the step that really needs the real service waits.
- Add a task the moment you discover it. Update the "Blockers / needs from owner" line in STATUS to point at it.

## 2. Write each task so a non-engineer can finish it alone

Use the template's format. Every task has:
- **Why:** one line, in plain words.
- **Cost:** free, or the price, including whether a card is needed and the free-tier limits.
- **Time:** e.g. "about 5 minutes".
- **Steps:** numbered, click by click, with the exact URL, the button names as they appear on screen, and which options to pick ("choose the Free plan", "region: closest to your users, e.g. Frankfurt").
- **What to hand back:** exactly which value to provide and where it goes (see §3).
- **Done when:** how you'll confirm it worked.

Before writing steps for a third-party site, **check its current docs or signup page.** Screens and plan names change, and wrong steps are worse than none. If you can't verify, say "the screen may look slightly different" and describe what to look for.

Prefer the options with the least risk to the owner:
- free tiers first
- spending limits or budget alerts turned on during setup
- least-privilege keys (e.g. a restricted key, not the account's master key)
- a separate account or project per app

## 3. Secret handoff: keys never go through chat

Chat transcripts are stored and may be sent to model providers. Treat anything pasted into chat as exposed.

- **Local development:** tell the owner to open the project's `.env` file (create it from `.env.example` for them, with the variable name already present and empty), paste the value after the `=`, and save. Confirm `.env` is in `.gitignore` before asking.
- **CI and hosting:** the owner pastes the value into the provider's dashboard (e.g. Vercel → Project → Settings → Environment Variables, or GitHub → repo → Settings → Secrets and variables → Actions). Give the exact path. Alternatively, have them run a command themselves that prompts for the value, such as `gh secret set NAME` (in Claude Code: type `! gh secret set NAME` so it runs in the session without the value ever reaching you).
- **Verify without revealing.** Check that the variable is set and works, e.g. make one cheap API call or print only its length or first 4 characters. Never print, log or commit the full value.
- **If a secret is pasted into chat or committed anyway:** say so plainly, treat it as compromised, add a task to rotate it (create a new key, delete the old one) and, if it was committed, remove it from git history. Do this before continuing.

## 4. Follow up

- At session start (Step 0), check `docs/OWNER-TODO.md` for tasks the owner has ticked, and verify each one.
- Mark a task ✅ only after you've verified it works, not when the owner says it's done.
- Every gate brief's "Things only you can do" section shows the open tasks, the earliest "needed by" first, and links to `docs/OWNER-TODO.md`.
