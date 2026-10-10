# Code quality standards

The review standard follows Google's engineering practice: **approve a change once it definitely improves overall code health, even if it isn't perfect. Never approve one that makes code health worse.**

| ID | Rule | Profile | Check |
|---|---|---|---|
| CQ-01 | **Formatter and linter** with zero warnings, using a committed config (Prettier + ESLint, Ruff, gofmt…). | P1 | auto |
| CQ-02 | **Strict typing.** TS `strict: true`, no `any` without a comment explaining why. Python type hints plus mypy/pyright on all non-test code. | P1 | auto |
| CQ-03 | **Readable names.** Intention-revealing, domain vocabulary from the PRD, no unexplained abbreviations. | P1 | Review |
| CQ-04 | **Small units.** Functions do one thing. Lint limits: cyclomatic complexity ≤ 10, function ≤ ~50 lines, file ≤ ~400 lines, unless an ADR says otherwise. | P2 | auto (lint rules) |
| CQ-05 | **No duplication** of business rules: a single source of truth. Small incidental duplication is fine. Don't abstract before the third use. | P1 | Review |
| CQ-06 | **Errors handled deliberately.** Never swallow exceptions. Fail fast on programmer errors. Return typed or explicit errors for expected failures. User-facing messages are helpful and leak no internals. | P1 | Review + lint (no empty catch) |
| CQ-07 | **Validate at boundaries.** All external input is parsed through a schema (Zod/Pydantic) at the edge. Inside the core, trust the types. | P1 | Review |
| CQ-08 | **No dead code** or commented-out blocks. TODOs carry a TECH-DEBT ID. | P1 | auto (lint) + review |
| CQ-09 | **Comments explain *why*,** not what. Public modules and APIs have doc comments. Non-obvious decisions link an ADR. | P1 | Review |
| CQ-10 | **Conventional Commits** with the REQ tag: `feat(notes): add summary export [REQ-014]`. Small, focused commits. | P1 | auto (commitlint, optional) |
| CQ-11 | **Semantic Versioning** for releases and any published API or package. A changelog is generated from the commits. | P2 | Release check |
| CQ-12 | **Dependencies justified.** No new dependency for something achievable in a few lines. Follow `supply-chain.md` for selection. | P1 | Review |
| CQ-13 | **Logging.** Structured (JSON), with levels, a request/correlation ID, and **no secrets or personal data**. | P2 | Review + grep check |
| CQ-14 | **Concurrency safety.** Shared state is protected, async errors are awaited and handled, no fire-and-forget without error capture. | P1 | Review + lint (no-floating-promises) |
| CQ-15 | **Configuration, not magic numbers.** Limits, URLs, model IDs and feature flags are named constants or config values. | P1 | Review |
| CQ-16 | **Code review on every change** by a reviewer other than the author. Findings are prioritized as critical, important or minor, and the review checks design, functionality, complexity, tests, naming, comments and docs. | P1 | Process (swe-reviewer) |
