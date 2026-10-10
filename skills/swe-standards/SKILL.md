---
name: swe-standards
description: Engineering standards handbook for the swe-orchestrator team. Industry baselines (ISO/IEC 25010 quality model, C4/12-factor architecture, Google code-review standard, test pyramid, OWASP Top 10:2025 and ASVS 5.0, OWASP LLM Top 10:2025, SLSA/SBOM supply chain, SRE/SLOs and DORA, WCAG 2.2 AA, privacy-by-design) as compact checklists with IDs, rigor profiles and check methods, plus the Definition of Done. Use when setting NFRs, designing, implementing, reviewing, security-checking or releasing, and whenever a role must cite which standard a decision or finding is based on.
---

# Engineering standards: the team's rulebook

The models already *know* best practices. This handbook makes them **binding, selected for the project's risk level, and checkable**. Every role cites rule IDs (e.g. `SEC-03`, `TST-05`) in plans, reviews, ADRs and gate briefs, so "is this good enough?" always has a concrete answer.

## 1. Rigor profile: chosen once, applied everywhere

The architect proposes a profile at Gate 2, based on the PRD. The owner approves it there. Record it in `docs/ARCHITECTURE.md` and in the project `AGENTS.md`.

| Profile | Use when | In short |
|---|---|---|
| **P1 Prototype** | Only the owner or a few invited testers use it. No sensitive data. Throwaway or validation | Core rules only: tests on business logic, secrets safe, basic security |
| **P2 Production** *(default)* | Real users, public internet, personal data, or payments through a provider | All P1 rules plus the full baseline: e2e tests, OWASP baseline, SLOs, backups, accessibility AA, SBOM |
| **P3 High-assurance** | Health, finance, children, regulated or critical data. Enterprise customers asking for security reviews | All P2 rules plus a stricter verification level, threat modeling per feature, signed provenance, formal privacy work, pen test before launch |

Every rule below is tagged with the **minimum profile** it applies to. A rule tagged P1 applies to P1, P2 and P3. A rule tagged P2 applies to P2 and P3.

## 2. The handbook: load only the part your role needs

| File | Covers | Mainly used by |
|---|---|---|
| [references/quality-attributes.md](references/quality-attributes.md) | ISO/IEC 25010:2023 → NFR checklist and defaults | requirements-engineer, architect |
| [references/architecture.md](references/architecture.md) | C4, modularity, 12-factor, API and data design, ADRs | architect, reviewer |
| [references/code-quality.md](references/code-quality.md) | Code review standard, readability, errors, typing, commits and versioning | implementer, reviewer |
| [references/testing.md](references/testing.md) | Test pyramid, coverage, e2e, contracts, flaky-test policy | implementer, reviewer |
| [references/security.md](references/security.md) | OWASP Top 10:2025 controls, ASVS 5.0 level per profile, scanners | security, reviewer |
| [references/ai-llm.md](references/ai-llm.md) | OWASP LLM Top 10:2025 controls, eval standards | ai-engineer, security |
| [references/supply-chain.md](references/supply-chain.md) | Dependencies, lockfiles, SBOM, SLSA, licenses | security, release-sre |
| [references/reliability-ops.md](references/reliability-ops.md) | SLOs, resilience, observability, backups, deploys, incidents, DORA | architect, release-sre |
| [references/accessibility-ux.md](references/accessibility-ux.md) | WCAG 2.2 AA essentials, UX quality, i18n | implementer, reviewer |
| [references/privacy-data.md](references/privacy-data.md) | Data minimization, retention, user rights, AI-provider data handling | requirements-engineer, security |

## 3. Definition of Done (applies at every profile unless noted)

**A task is done when:**
- it was built test-first (`TST-01`), the tests pass, and `scripts/check.sh` is green: lint, types, format, secret scan
- no rule at the project's profile is violated, or an ADR records the exception (§4)
- it's committed with a REQ-tagged Conventional Commit message (`CQ-10`)

**A milestone is done when:**
- every task in it is done
- an independent reviewer verified every REQ, NFR and AIQ in it: criteria met and journey exercised (`TST-06`). Each verified item is `pass` in `docs/traceability.json`.
- the review found no critical or important issues, and the security checklist passed with no critical or high findings
- coverage meets the thresholds in `TST-04`, and there are no new flaky or skipped tests (`TST-09`)
- docs are updated: MODULES, ARCHITECTURE (if the design changed), AGENTS commands, and an ADR for each significant decision
- for **P2+**: the e2e journeys pass and the automated accessibility check passes (`A11Y-01`)

**A release is done when:**
- every MVP item is `pass`
- `docs/LAUNCH.md` is fully green
- SLOs are defined and monitored (`OPS-01`)
- a backup restore has been tested (`OPS-08`)
- the rollback has been rehearsed or documented (`OPS-11`)
- for **P2+**: an SBOM has been generated (`SUP-05`) and a DAST baseline has been run (`SEC-12`)
- for **P3**: an external pen test has been done or scheduled, and its findings triaged

## 4. Exceptions

Rules can be waived only deliberately:
- **An ADR** records the rule ID, why it doesn't apply or can't be met now, the risk, and when to revisit it.
- **A `docs/TECH-DEBT.md` entry** is added if the gap is temporary.
- **Waivers of security or privacy rules** at P2+ must appear in the next gate brief, in plain language.

## 5. How roles use this
- **Cite IDs** in review findings ("violates `SEC-01`: no ownership check on GET /notes/:id"), plans, ADRs and gate briefs.
- **Prefer mechanical checks.** Each rule lists how it's checked. Rules marked *auto* belong in `scripts/check.sh`, CI or the pre-commit hook (see `swe-orchestrator/references/guardrails.md`).
- **Don't gold-plate.** Apply the project's profile, not the strictest one. Over-engineering a P1 prototype is also a defect.
- **Verify current versions.** Standards and tools evolve. When a rule names a tool or version, check its current docs before configuring it.
