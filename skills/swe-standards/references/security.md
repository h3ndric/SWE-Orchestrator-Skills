# Security standards

**Baselines:**
- [OWASP Top 10:2025](https://owasp.org/Top10/2025/): what most commonly goes wrong.
- [OWASP ASVS 5.0](https://owasp.org/www-project-application-security-verification-standard/): a verification checklist with ~350 requirements in 17 chapters and three cumulative levels.

**ASVS target per profile:**
- **P1:** the controls below, which roughly match ASVS L1 for the features in use.
- **P2:** ASVS **L1 in full**, plus L2 for authentication, session management, authorization and data protection.
- **P3:** ASVS **L2 in full**, and L3 for the most critical functions such as payments and medical records.

Always check the current ASVS text for the chapters that apply. Don't rely on memory.

## Controls mapped to OWASP Top 10:2025

| ID | OWASP 2025 | Control | Profile | Check |
|---|---|---|---|---|
| SEC-01 | A01 Broken Access Control | Deny by default. Every endpoint and action checks authentication **and** resource ownership or role (prevents IDOR). Authz logic is centralized. Includes SSRF defense: allow-list outbound URLs and block internal IP ranges. | P1 | Authz negative tests (`TST-13`) + review |
| SEC-02 | A02 Security Misconfiguration | Secure headers (CSP, HSTS, X-Content-Type-Options, frame-ancestors), restrictive CORS, debug off, no default credentials, minimal exposed ports, cloud storage private by default. | P1 | auto (header scan) + review |
| SEC-03 | A03 Software Supply Chain Failures | Follow `supply-chain.md`: lockfiles, vulnerability scanning, vetted dependencies, CI hardening. | P1 | auto |
| SEC-04 | A04 Cryptographic Failures | TLS everywhere. Passwords hashed with Argon2id or bcrypt, never custom crypto. Secrets in env or a secret manager, never in code. Sensitive data encrypted at rest (managed DB encryption is fine). | P1 | Review + secret scan |
| SEC-05 | A05 Injection | Parameterized queries or an ORM. No shell, eval or template execution of input. Output encoding in the UI. Avoid `dangerouslySetInnerHTML` / `|safe`, and sanitize when unavoidable. Includes XSS. | P1 | auto (SAST: semgrep) + review |
| SEC-06 | A06 Insecure Design | Threat model (`ARC-15`), abuse cases in the PRD for risky features, rate limits on expensive or auth endpoints, business-logic limits (quotas, amounts). | P2 | Review |
| SEC-07 | A07 Authentication Failures | Use a proven auth provider or library. MFA available (P2) or enforced for admins (P3). Generic login errors. Brute-force protection. Secure session cookies (HttpOnly, Secure, SameSite). Session expiry and rotation on login. | P1 | Review + tests |
| SEC-08 | A08 Software or Data Integrity Failures | Verify webhook signatures. No unsafe deserialization. Signed or verified artifacts in CI/CD (see `SUP-07`). Integrity checks on critical data flows. | P2 | Tests + review |
| SEC-09 | A09 Security Logging and Alerting Failures | Log auth events, access denials, admin actions and input-validation failures, without secrets or personal data. **Alert** on anomalies (spikes in 401/403/500, unusual spend). | P2 | Review + alert test |
| SEC-10 | A10 Mishandling of Exceptional Conditions | Fail closed: errors never grant access or skip checks. Global error handler. No stack traces to users. Resource cleanup on failure. Timeouts on all I/O. | P1 | Review + tests |

## Process controls

| ID | Control | Profile | Check |
|---|---|---|---|
| SEC-11 | **Automated scanning in CI:** SAST (semgrep), secrets (gitleaks, also as a pre-commit hook), dependencies (osv-scanner / npm audit / pip-audit), container image (trivy) if containers are used. High or critical findings block the merge. | P1 | auto |
| SEC-12 | **DAST baseline** (OWASP ZAP baseline scan) against staging before launch and on major releases. | P2 | auto |
| SEC-13 | **Least privilege.** Separate prod credentials, scoped API keys, DB users without superuser rights, CI tokens with minimal permissions. | P1 | Review |
| SEC-14 | **Security review per milestone** (swe-security checklist) and a full audit before launch. | P1 | Process |
| SEC-15 | **External penetration test** before launch, with findings triaged and fixed per severity. | P3 | Process |
| SEC-16 | **Vulnerability response.** Fix critical issues within 7 days and high within 30. Keep a `SECURITY.md` with a contact for public projects. | P2 | Process |
