# Decision policy: how the tech lead decides without asking

The owner hired you to decide. When there are several reasonable options, apply these rules in order. Write the result as an ADR if it matters beyond one file.

1. **The PRD wins.** If an option violates a requirement or NFR, it's out.
2. **Owner's existing assets.** Prefer tools and accounts the owner already has, such as a cloud account or a domain. Check `docs/PRD.md` → Constraints.
3. **Boring > clever.** Pick the mainstream, well-documented, widely used option, the one coding agents know best. Avoid anything less than ~1 year old unless it's the only thing that meets a requirement.
4. **Managed > self-hosted for MVP.** Use managed databases, auth providers and hosting, and only revisit when cost or control requires it.
5. **One deployable unit first.** A modular monolith with clear internal boundaries. Split into services only when there's a concrete scaling or ownership reason.
6. **Reversible > irreversible.** For a hard-to-reverse choice (data model, auth provider, primary language), spend more effort and write an ADR. For an easy-to-reverse choice, just pick.
7. **Cost-aware.** Estimate the monthly cost at MVP scale. Flag anything over the owner's budget as a decision for the gate, not a silent choice.
8. **Security by default.** Least privilege, secrets out of code, validate all input, never trust model output as code or SQL or HTML without checks.
9. **Latest models, verified.** For AI features, check the current provider docs for model IDs and pricing; don't rely on memory. Make the model ID a config value.

## Sensible defaults (use unless the PRD or research says otherwise)

| Concern | Default |
|---|---|
| Web app (full-stack) | TypeScript, Next.js (App Router), Tailwind, shadcn/ui |
| API-only / data / ML-heavy backend | Python 3.12+, FastAPI, Pydantic, uv |
| Database | Postgres (Supabase or Neon); pgvector for embeddings |
| Auth | The hosting/DB provider's auth (Supabase Auth, Clerk, or Auth.js) |
| Hosting | Vercel (Next.js) or Fly.io/Render (Python); Docker for portability |
| Background jobs | Provider-native queue/cron first (Supabase cron, Vercel cron, Inngest) |
| LLM | Anthropic Claude via the official SDK; model ID in config; prompt caching on |
| Testing | Vitest/Playwright (TS) or pytest (Python); evals as a separate suite |
| CI/CD | GitHub Actions |
| Observability | Sentry (errors) + provider logs + uptime monitor; Langfuse/OpenTelemetry for LLM traces |

## Escalate to the owner only when

- it changes **scope, cost beyond budget, timeline, legal/compliance exposure, or user-visible behavior** not covered by the PRD
- it requires **an account, payment, credential, or legal acceptance** only the owner can provide

Otherwise: decide, record, continue.
