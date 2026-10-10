# Quality attributes (based on ISO/IEC 25010:2023)

ISO/IEC 25010:2023 defines nine product-quality characteristics. Use them as a **completeness checklist for non-functional requirements (NFRs)**. Every characteristic must be either covered by an NFR in the PRD or explicitly marked "not relevant" with a reason.

The defaults below are what to propose when the owner says "you decide". Adjust them to the rigor profile.

| ID | Characteristic | Ask / decide | Sensible default (P2) | Verified by |
|---|---|---|---|---|
| QA-01 | **Functional suitability**: complete, correct, appropriate | Are all journeys covered? What does "correct" mean for each? | Every REQ has Given/When/Then criteria | Tests + traceability |
| QA-02 | **Performance efficiency**: time, resources, capacity | Expected users and peak load? Acceptable wait? | p95 API < 500 ms, page interactive < 2.5 s on mid-range mobile, sized for 10× launch traffic | Load test (k6), Lighthouse |
| QA-03 | **Compatibility**: coexistence, interoperability | Which browsers, devices and integrations? | Last 2 versions of evergreen browsers, mobile-responsive, documented API formats | e2e on Chromium + WebKit |
| QA-04 | **Interaction capability** (formerly usability): learnability, operability, error protection, accessibility | Who are the users? Their tech comfort? | WCAG 2.2 AA; core journey completable with no instructions | axe in e2e, owner tries it at Gate 3 |
| QA-05 | **Reliability**: availability, fault tolerance, recoverability | How bad is downtime? How much data loss is tolerable? | 99.5% monthly availability, RPO ≤ 24 h, RTO ≤ 4 h | SLO monitoring, restore test |
| QA-06 | **Security**: confidentiality, integrity, non-repudiation, accountability, authenticity, resistance | What data? Who are the attackers? | OWASP baseline per `security.md` at the project's profile | Security review, scanners |
| QA-07 | **Maintainability**: modularity, reusability, analysability, modifiability, testability | How long will it live? Who changes it? | Module boundaries enforced, coverage per `TST-04`, ADRs | Boundary checks, coverage |
| QA-08 | **Flexibility** (formerly portability): adaptability, scalability, installability, replaceability | Might hosting, scale or providers change? | Containerizable, config via env, LLM/provider behind an interface | Builds in CI from a clean checkout |
| QA-09 | **Safety**: operational constraint, risk identification, fail-safe, hazard warning | Can the software cause harm (physical, financial, psychological)? | Fail-safe defaults, confirmation for irreversible actions, AI actions human-approved where harmful | Review + AI evals |

## Writing NFRs well
- **Measurable:** a number, a unit, a percentile, and the conditions. For example: "p95 < 500 ms at 50 req/s".
- **Testable:** name the check that will prove it.
- **Traceable:** each NFR gets an ID (`NFR-NNN`) in `docs/traceability.json`.
- **Cost-aware:** each tighter target costs money and effort. State the cost trade-off at Gate 2.
