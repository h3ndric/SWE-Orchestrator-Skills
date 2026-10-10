# Privacy and data-protection standards

**Baseline:** privacy by design and by default, following GDPR principles: lawfulness, purpose limitation, data minimization, accuracy, storage limitation, integrity and confidentiality, accountability. These are a sound default even outside the EU.

This file gives **engineering guidance, not legal advice.** For P3, or for regulated data (health, finance, children), flag it at Gate 1 or 2 that the owner should get qualified legal review.

| ID | Rule | Profile | Check |
|---|---|---|---|
| PRV-01 | **Data inventory.** `ARCHITECTURE.md` lists every personal-data field: what it is, why it's needed, where it's stored, who can access it, its retention period, and which third parties receive it. | P2 | Review |
| PRV-02 | **Minimization.** Collect only what a REQ needs. No "might be useful later" fields. Optional fields really are optional. | P1 | Review vs PRD |
| PRV-03 | **Classification.** Tag data as public, internal, personal or sensitive (health, financial, biometric, children's, credentials). Sensitive data gets stronger controls: encryption, access logging, stricter retention. | P2 | Review |
| PRV-04 | **Retention and deletion.** A retention period per data type, with automated deletion or anonymization jobs. Backups expire in line with retention. | P2 | Job exists + test |
| PRV-05 | **User rights.** Users can export their data and delete their account and data (including from search, vector indexes and caches), and the flow is tested. | P2 | e2e test |
| PRV-06 | **Consent and transparency.** A privacy policy that matches actual data flows. A cookie or tracking consent banner where non-essential tracking exists. A clear notice when content is processed by AI. | P2 | Review at Gate 4 |
| PRV-07 | **Third parties and AI providers.** Data-processing terms are reviewed. Use API offerings that don't train on customer data, with zero or limited retention where available. Record each provider's region and purpose in the inventory. | P1 | Review |
| PRV-08 | **No personal data in logs, analytics, error trackers or prompts** beyond what's necessary. Scrub or redact at the source. | P1 | Review + grep check |
| PRV-09 | **Access control on personal data.** Least privilege for staff and admin access, with admin access logged (`SEC-09`). | P2 | Review |
| PRV-10 | **Breach readiness.** The runbook has a data-breach section: contain, assess, notify the owner, and note any legal notification timelines to check, e.g. GDPR's 72 hours. | P2 | Runbook check |
| PRV-11 | **DPIA-style risk assessment** for high-risk processing (large-scale sensitive data, profiling, AI decisions about people), recorded in an ADR. | P3 | Exists |
