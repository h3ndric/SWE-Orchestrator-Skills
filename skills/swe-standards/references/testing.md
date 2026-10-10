# Testing standards

The shape is the **test pyramid**: many fast unit tests, fewer integration tests, and a few end-to-end journeys. AI quality is covered by a separate eval suite (`ai-llm.md`).

| ID | Rule | Profile | Check |
|---|---|---|---|
| TST-01 | **Test-first for behavior** (red → green → refactor). Every bug fix starts with a failing regression test. | P1 | Review (commit order) |
| TST-02 | **Tests name their requirement:** `REQ-012: rejects files over 20 MB`. Each acceptance criterion maps to at least one test. | P1 | auto (traceability scan) |
| TST-03 | **Right level for each test.** Domain rules → unit. DB, queues and adapters → integration against real services (Testcontainers or a local DB, not mocks). User journeys → e2e. | P1 | Review |
| TST-04 | **Coverage thresholds**, enforced in CI. P1: ≥ 60% lines on domain/service code. P2: ≥ 80% lines on domain/service, and ≥ 80% on changed lines. P3: ≥ 90% domain plus branch coverage tracked. Coverage is a floor, not a goal. Assertions matter more. | P1 | auto |
| TST-05 | **e2e for every user-facing journey,** with Playwright (or a platform equivalent) against a running app, as a real user would do it. Use stable selectors (roles, labels, test IDs). | P2 | auto (CI) |
| TST-06 | **Independent verification.** Whoever marks a requirement `pass` didn't write the code: they re-run the tests and exercise the journey. | P1 | Process |
| TST-07 | **Tests are meaningful.** They assert behavior, not implementation details. No tests that can't fail, and no snapshot-only tests for logic. Each test is independent, order-free and deterministic: control the clock, randomness and network. | P1 | Review |
| TST-08 | **Test data.** Use factories or builders, not shared mutable fixtures. No production data in tests. Synthetic personal data only. | P1 | Review |
| TST-09 | **Zero tolerance for flakiness.** A flaky test is quarantined within one day, with a TECH-DEBT entry, then fixed or deleted. Skipped tests need a linked reason. | P1 | auto (CI report) |
| TST-10 | **Contract tests** for external APIs and webhooks: validate the requests and responses we depend on, against recorded or official schemas. | P2 | auto |
| TST-11 | **Performance check** against the NFRs before launch, and again after major changes (k6/autocannon for APIs, Lighthouse for web). | P2 | auto/manual |
| TST-12 | **Migration test.** CI applies all migrations to an empty DB and runs the integration tests. Rollback or expand-contract is verified for risky changes. | P2 | auto |
| TST-13 | **Security tests**: authz negative tests (user A can't access B's data) for every resource endpoint, plus input-validation edge cases. | P2 | auto |
| TST-14 | **Mutation testing** (Stryker, mutmut) on core domain modules, run periodically to check test strength. | P3 | auto (scheduled) |
| TST-15 | **Fast feedback.** The unit suite runs in < 1 min, and smoke in < 1 min. If CI takes over 10 min, parallelize it. | P2 | auto (timing) |
