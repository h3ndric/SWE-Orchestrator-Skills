# AI / LLM standards

**Baseline:** [OWASP Top 10 for LLM Applications 2025](https://genai.owasp.org/llm-top-10/). For **P3**, also align with the NIST AI Risk Management Framework: govern, map, measure, manage. Check the current versions before applying them.

## Controls mapped to OWASP LLM Top 10:2025

| ID | OWASP LLM 2025 | Control | Profile | Check |
|---|---|---|---|---|
| AI-01 | LLM01 Prompt Injection | Treat all non-system text (user input, documents, web pages, tool results, emails) as **data**. Use clear delimiters, keep instructions separate, and give the model least privilege. Never rely on the prompt alone for security. Enforce rules in code. | P1 | Adversarial eval cases + review |
| AI-02 | LLM02 Sensitive Information Disclosure | Minimize the personal data sent to the model. Redact where possible. Don't put secrets in prompts. Check the provider's data-retention terms (see `PRV-07`). Filter outputs for leaked personal data where relevant. | P1 | Review + eval cases |
| AI-03 | LLM03 Supply Chain | Use only reputable model providers and model sources. Pin model versions or IDs in config. Vet third-party plugins, MCP servers and datasets like any other dependency. | P1 | Review |
| AI-04 | LLM04 Data and Model Poisoning | Control what goes into the RAG index and any fine-tuning data: provenance, allow-listed sources, review of user-contributed content before indexing. | P2 | Review |
| AI-05 | LLM05 Improper Output Handling | Model output is **untrusted input**. Validate it with a schema (structured outputs), encode it before rendering, and never execute it as code, SQL or shell, or pass it into URLs, without strict validation. | P1 | Tests + review |
| AI-06 | LLM06 Excessive Agency | Give tools minimal scope and permissions. Read-only by default. Require human confirmation for irreversible, financial or external actions (sending email, payments, deletes). Cap the number of steps. | P1 | Review + tests |
| AI-07 | LLM07 System Prompt Leakage | Assume the system prompt will leak. Put no secrets, credentials or authorization logic in it. | P1 | Review |
| AI-08 | LLM08 Vector and Embedding Weaknesses | Retrieval respects access control: filter by tenant or user **in the query**, not after retrieval. Keep tenants' indexes separated. Validate any data before embedding it. | P2 | Authz tests on retrieval |
| AI-09 | LLM09 Misinformation | Ground answers in sources. Show citations where the PRD requires them, and check that each citation exists in the source. Show uncertainty and fallbacks. Measure hallucination in evals. | P1 | Evals |
| AI-10 | LLM10 Unbounded Consumption | Max tokens and timeouts on every call. Per-user and global rate limits and quotas. Budget alerts at the provider. Caching. Detect runaway loops. | P1 | Tests + config review |

## Engineering and quality standards

| ID | Rule | Profile | Check |
|---|---|---|---|
| AI-11 | **Eval suite per AIQ.** A golden set (≥ 10 cases at P1, 30–50+ at P2), deterministic checks first, then an LLM judge with a versioned rubric. The pass threshold comes from the PRD. Runs in CI when prompts, models or retrieval change. | P1 | auto |
| AI-12 | **Prompts are code.** Versioned files, reviewed, with an eval run on every change. The prompt version is logged with each output. | P1 | Review |
| AI-13 | **Interface and fallback.** The LLM client sits behind an interface, with fakes in unit tests. A fallback model or graceful degradation handles provider outages. Retries use backoff. | P2 | Tests |
| AI-14 | **Tracing.** Every call logs model, prompt version, tokens, latency, cost and outcome (Langfuse or OpenTelemetry), with personal data redacted. | P2 | Review |
| AI-15 | **Cost model** at Gate 2 (cost per action × volume), and a monthly budget alert in production. | P1 | Gate brief |
| AI-16 | **Human oversight** for consequential outputs (medical, legal, financial or safety-related): review or approval flows, clear AI labeling, and user feedback capture. | P3 | Review |
| AI-17 | **Bias and safety checks** in the eval set wherever outputs affect people differently, e.g. by language or demographic. | P2 | Evals |
