# Reliability and operations standards

**Baselines:**
- Google SRE practices: SLIs, SLOs and error budgets, symptom-based alerting, blameless postmortems.
- DORA's four key metrics: deployment frequency, lead time for changes, change failure rate, and time to restore service.

| ID | Rule | Profile | Check |
|---|---|---|---|
| OPS-01 | **SLOs defined** from the PRD NFRs. For example: availability 99.5%/month, p95 latency < 500 ms. Each SLO has an SLI that is actually measured. An error budget guides release pace. | P2 | Dashboard exists |
| OPS-02 | **Health endpoints:** liveness, and readiness that checks dependencies. An external uptime monitor alerts the owner. | P1 | auto |
| OPS-03 | **Timeouts on every network call.** Retries with exponential backoff and jitter, only for idempotent operations. Circuit breaker or fallback for critical dependencies (LLM, payments). | P2 | Review + tests |
| OPS-04 | **Graceful degradation.** When a dependency fails, show a useful degraded experience, not a crash. Queue work for later where possible. | P2 | Tests (fault injection) |
| OPS-05 | **Structured logs** with a correlation/request ID across services, and no personal data or secrets (`CQ-13`). Retention is defined. | P2 | Review |
| OPS-06 | **Metrics and traces.** RED metrics (rate, errors, duration) per endpoint, and USE (utilization, saturation, errors) for resources, via OpenTelemetry where practical. Error tracking (Sentry or similar) with release tagging. | P2 | Dashboard exists |
| OPS-07 | **Symptom-based alerting.** Alert on user-visible symptoms (SLO burn, error-rate spikes, uptime), not on every cause. Each alert links to a runbook step. No alert that nobody would act on. | P2 | Alert list review |
| OPS-08 | **Backups and restore.** Automated backups of the DB and user files. RPO and RTO are documented. **A restore is tested** before launch, and quarterly after that at P3. | P1 (enabled) / P2 (tested) | Restore drill log |
| OPS-09 | **Environments.** Dev and prod, plus staging or preview at P2. Parity in config shape. Prod data never copied to lower environments unless anonymized. | P2 | Review |
| OPS-10 | **Automated deploys** from main via CI, reproducible and versioned. Smoke test after each deploy, with auto-rollback or a quick manual rollback. | P1 | auto |
| OPS-11 | **Rollback path** documented and rehearsed once. DB changes use expand/contract, so rolling the app back is safe. Feature flags for risky features. | P2 | Rehearsal log |
| OPS-12 | **Runbook** (`docs/RUNBOOK.md`): deploy, roll back, rotate secrets, restore backup, respond to each alert, find logs and costs. Written so the owner could follow it with an AI agent. | P1 | Exists + reviewed |
| OPS-13 | **Incidents:** stabilize first (roll back), then communicate, fix with a regression test, and write a blameless postmortem in `docs/incidents/`. | P2 | Process |
| OPS-14 | **Capacity and cost.** A monthly cost review against the budget. Autoscaling or limits configured. Budget alerts at each provider. | P2 | Gate 4 brief |
| OPS-15 | **DORA metrics** tracked once live: deploy frequency, lead time, change failure rate, time to restore. They're reviewed in increment reviews. | P3 | Dashboard / report |
