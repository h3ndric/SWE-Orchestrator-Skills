# Accessibility and UX standards

**Baseline:** [WCAG 2.2](https://www.w3.org/TR/WCAG22/) **Level AA** for anything user-facing at P2+. WCAG 2.2 became a W3C Recommendation in October 2023. Check the W3C for later versions.

| ID | Rule | Profile | Check |
|---|---|---|---|
| A11Y-01 | **Automated a11y checks** with axe-core in the e2e suite on every main page and state, with zero serious or critical violations. Lighthouse accessibility score ≥ 90. | P2 | auto |
| A11Y-02 | **Keyboard operable.** Every action is reachable and usable by keyboard, with a logical focus order, a **visible focus indicator** that isn't hidden by sticky headers (WCAG 2.2), and no keyboard traps. | P2 | e2e keyboard test + manual |
| A11Y-03 | **Semantic HTML first:** real buttons, links, headings, landmarks and form labels. ARIA only when native elements can't do the job. | P1 | Review + axe |
| A11Y-04 | **Contrast.** Text at least 4.5:1 (3:1 for large text and UI components). Information is never conveyed by color alone. | P2 | auto (axe) |
| A11Y-05 | **Forms.** Visible labels, clear errors next to the field with fix guidance, no re-entering information already given (WCAG 2.2 Redundant Entry), and accessible authentication with no cognitive puzzles required (WCAG 2.2). | P2 | Review + e2e |
| A11Y-06 | **Target size.** Interactive targets are at least 24×24 CSS px (WCAG 2.2). Dragging actions have a single-pointer alternative (WCAG 2.2). | P2 | Review |
| A11Y-07 | **Media and images.** Alt text for meaningful images (decorative ones get `alt=""`), captions for video, no autoplaying audio. | P2 | axe + review |
| A11Y-08 | **Resilient layout.** Responsive from 320 px wide, usable at 200% zoom, respects `prefers-reduced-motion`. | P2 | e2e at mobile viewport |
| UX-01 | **Every state designed:** loading, empty, error, success and partial. No dead ends. Every error tells the user what to do next. | P1 | Review at Gate 3 |
| UX-02 | **Irreversible actions** need confirmation or an undo. Destructive actions are visually distinct. | P1 | Review |
| UX-03 | **Perceived performance:** feedback within 100 ms of an action, skeletons or spinners for waits over 1 s, streaming for AI generation. | P2 | Review + Lighthouse |
| UX-04 | **Consistency:** one design system or component library (e.g. shadcn/ui), consistent spacing, type and wording. | P1 | Review |
| UX-05 | **i18n-ready** when the PRD names multiple languages or regions: no hard-coded strings, locale-aware dates, numbers and currency, room for text expansion. | P2 (if multi-locale) | Review |
