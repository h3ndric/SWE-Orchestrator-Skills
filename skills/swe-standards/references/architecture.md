# Architecture standards

| ID | Rule | Profile | Check |
|---|---|---|---|
| ARC-01 | **Document with C4.** Keep a System Context diagram and a Container diagram (Mermaid) in `ARCHITECTURE.md`. Add Component diagrams only for complex containers. | P1 | Review |
| ARC-02 | **Modular monolith first.** One deployable unit with explicit modules (`docs/MODULES.md`). Split into services only for a documented scaling or ownership reason, recorded in an ADR. | P1 | Review |
| ARC-03 | **Enforced boundaries.** Dependencies point one way: UI → application/service → domain ← infrastructure adapters. No cycles. Rules are encoded in a boundary checker. | P2 | auto (dependency-cruiser / import-linter) |
| ARC-04 | **Domain logic is pure.** Business rules contain no I/O, so they're testable without a DB, network or LLM. External systems sit behind interfaces (ports/adapters). | P1 | Review |
| ARC-05 | **12-factor config.** Config comes from the environment, there's one codebase across many deploys, builds are stateless, logs go to stdout, and dev and prod are similar. | P1 | Review + `.env.example` check |
| ARC-06 | **ADRs for significant decisions:** anything hard to reverse, costly, or cross-cutting. Record the context, options, decision and consequences. A superseded ADR is kept and linked. | P1 | Review |
| ARC-07 | **API design** (HTTP): resource-oriented URLs, correct methods and status codes, JSON, errors as RFC 9457 Problem Details, pagination on every list, consistent naming. | P2 | Review + contract tests |
| ARC-08 | **API evolution.** Versioning strategy (URL or header). Only additive changes within a version. Breaking changes need a new version and a deprecation window. | P2 | Review |
| ARC-09 | **Idempotency.** Retried writes are safe: idempotency keys on payment, order and other side-effect endpoints, and on webhook handlers. | P2 | Tests |
| ARC-10 | **Data integrity in the database.** Constraints (NOT NULL, FK, UNIQUE, CHECK) live in the schema, not just in app code. Transactions for multi-step writes. | P1 | Review of migrations |
| ARC-11 | **Versioned migrations.** Forward-only and reviewed. Use expand/contract for zero-downtime changes. Never edit an applied migration. | P1 | CI runs migrations on a fresh DB |
| ARC-12 | **Async work** (jobs, queues, webhooks) is idempotent, retried with backoff, has a dead-letter or failed state, and is observable. | P2 | Tests + review |
| ARC-13 | **Time and money.** Store UTC timestamps with timezone. Represent money as integer minor units or decimal, never float. | P1 | Review |
| ARC-14 | **Simplicity budget.** Every new technology or infra piece must earn its place, with a one-line justification in the stack table. Prefer fewer moving parts. | P1 | Review |
| ARC-15 | **Threat model** at design time: a STRIDE pass over the Container diagram, with the top threats and mitigations in ARCHITECTURE §8. P3: per significant feature too. | P2 | Review |
