# Software supply-chain standards

**Baselines:**
- [SLSA](https://slsa.dev/) (Supply-chain Levels for Software Artifacts): build-track levels L0–L3. Check the current spec version.
- NIST SSDF (SP 800-218): secure development practices.
- OpenSSF Scorecard: repository hygiene.

| ID | Rule | Profile | Check |
|---|---|---|---|
| SUP-01 | **Lockfiles committed** (package-lock / pnpm-lock / uv.lock / poetry.lock). CI installs from the lockfile only (`npm ci`, `uv sync --frozen`). | P1 | auto |
| SUP-02 | **Dependency selection.** Prefer widely used, actively maintained packages (recent releases, several maintainers, healthy issue tracker). Check that the name is exact, because of typo-squatting and AI-hallucinated package names. Avoid one-function packages. | P1 | Review |
| SUP-03 | **Vulnerability scanning** in CI (osv-scanner / npm audit / pip-audit). High or critical findings block the merge unless an ADR waives them. | P1 | auto |
| SUP-04 | **Automated updates** (Dependabot or Renovate), grouped and run weekly. Updates must pass the full CI. | P2 | Config present |
| SUP-05 | **SBOM** (CycloneDX or SPDX), generated for every release and stored with it. | P2 | auto (release job) |
| SUP-06 | **License compliance.** Allow-list permissive licenses (MIT, Apache-2.0, BSD, ISC). Flag copyleft (GPL/AGPL) for review before use. | P2 | auto (license checker) |
| SUP-07 | **Build provenance.** Builds run on hosted CI from version control (SLSA Build L1–L2). For P3, generate signed provenance or attestations (e.g. GitHub artifact attestations, Sigstore). | P2 (L1–L2) / P3 (signed) | auto |
| SUP-08 | **CI hardening.** Workflow tokens default to minimal permissions. Pin third-party actions to a commit SHA. Secrets are scoped to environments. No secrets on PRs from forks. | P2 | auto (zizmor / actionlint, optional) |
| SUP-09 | **Branch protection.** Main requires green CI and review, with no force-push. Signed commits are optional at P3. | P2 | Repo settings |
| SUP-10 | **Container images.** Minimal base images, pinned by digest, a non-root user, scanned (trivy), and rebuilt regularly. | P2 (if containers are used) | auto |
| SUP-11 | **Repo hygiene** (OpenSSF Scorecard-style): `SECURITY.md`, a license file, dependency-update tooling, branch protection, CI tests. | P3 | Scorecard run |
