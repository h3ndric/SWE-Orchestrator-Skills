# Checkpoints and undo: "take it back to how it was at Gate 3"

Because all code **and** all docs live in git, every approved gate is a restore point. The owner should be able to undo a bad milestone with one sentence.

## 1. Tag every checkpoint

| When | Tag | Example |
|---|---|---|
| A gate is approved | `gate-<N>[-m<k>]-approved` | `gate-1-approved`, `gate-3-m2-approved` |
| Before starting a milestone | `m<k>-start` | `m3-start` |
| Before a risky change (big refactor, data migration, dependency upgrade) | `pre-<short-name>` | `pre-auth-swap` |

- Commit everything first (code and `docs/`), so the tag captures a clean state: `git tag -a gate-3-m2-approved -m "Owner approved Gate 3 (M2) on <date>"`.
- If the project has a remote, push tags too: `git push --follow-tags` (or `git push origin <tag>`).
- Record the tag in the gate file next to "✅ Approved <date>".

**Recommend an off-machine backup.** Until the project has a private GitHub (or similar) remote, everything lives on one laptop. Add "create a private GitHub repository" as an owner task at Gate 2 at the latest, and push after every gate.

## 2. When the owner asks to undo

Phrases like "undo", "go back to Gate 3", "throw away the last milestone", "it was better before".

1. **Show what would be lost first.** List the checkpoints (`git tag -l 'gate-*' 'm*-start'`), pick the one matching the request, and summarize in plain words what changes after it would disappear: features, fixes, docs updates, the commits count. Mention anything already **deployed** or any **database changes**, which git can't undo by itself.
2. **Get explicit confirmation.** This is destructive. Wait for "yes".
3. **Keep a safety copy.** `git branch backup/<YYYY-MM-DD>-before-undo` at the current state, so even the undo can be undone.
4. **Restore.** With a clean working tree: `git reset --hard <tag>`. If the branch was already pushed and others (people or CI) depend on it, use `git revert --no-edit <tag>..HEAD` instead, which adds new commits that undo the changes without rewriting history.
5. **Production and data.** If the undone work was deployed: redeploy the restored version using the runbook's rollback steps. If it included database migrations: apply the down migrations, or write a forward migration that restores the old shape. Never drop production data without a fresh backup and the owner's explicit OK.
6. **Re-sync the docs.** STATUS, ROADMAP, MODULES and traceability.json are restored with the tag. Add a line to STATUS explaining the undo, which tag, and where the backup branch is. Move any REQs that were undone back to `todo` if the restored ledger doesn't already show that.
7. **Ask what's next** only if it's unclear. Usually the owner's comment says what they want instead; treat that as a change request (see [gates.md](gates.md)).

## 3. Smaller undos

For "undo just that one change" (a single feature or fix), prefer `git revert <commit>` for the specific commits over resetting a whole milestone. Show the owner the list of commits in plain words before reverting.
