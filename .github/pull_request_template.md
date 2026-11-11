## Description
<!-- Provide a brief summary of the changes introduced in this PR. -->

## Related Issues / Roadmap Milestones
- Resolves #
- Related Roadmap Milestone: 

## Type of Change
- [ ] 🐛 Bug fix (non-breaking change fixing an issue)
- [ ] ✨ New feature (non-breaking change adding functionality)
- [ ] ⚡ Performance optimization
- [ ] ♿ Accessibility improvement
- [ ] 🧪 Testing & CI/CD workflow
- [ ] 📝 Documentation & Architecture update

## Definition of Done (DoD) Checklist
- [ ] **Architecture:** Clean & Feature-First architecture; zero business logic in UI widgets.
- [ ] **Financial Precision:** All money values stored and computed as 64-bit integer minor units (pesewas); no floating-point arithmetic.
- [ ] **Offline Reliability:** Fully operational with device in Airplane Mode; changes persist across application cold restarts.
- [ ] **Validation:** Input forms reject invalid, negative, or mathematically impossible values with friendly user feedback.
- [ ] **State Feedback:** Loading, Empty, Populated, and Error states explicitly handled.
- [ ] **Auditability:** Destructive actions void rather than hard delete; audit entries recorded.
- [ ] **Accessibility:** WCAG 2.1 AAA contrast for body text, Semantics wrappers on cards, and touch targets $\ge 48\times 48\text{ dp}$.
- [ ] **Testing:** Unit, integration, or widget tests added/updated; all tests pass locally (`flutter test`).
- [ ] **Code Formatting & Linting:** Code formatted with `dart format .` and passes `flutter analyze` without errors.

## Screenshots / Screen Recordings (if UI changes)
<!-- Attach screenshots or GIFs for visual changes across light, dark, and OLED themes. -->

