# PR Title

Format: <PROJECTKEY>-<issue-number>: type(scope): short description
Example: SF-123: feat(community): add tab registry

## 📋 Description
Brief description of what this PR does.

## 🎯 Jira
- Issue: SF-123
- Link: https://your-jira-domain/browse/SF-123

## 🔧 Type of Change
- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📚 Documentation update
- [ ] 🎨 Code style/formatting changes
- [ ] ♻️ Code refactoring (no functional changes)
- [ ] ⚡ Performance improvements
- [ ] 🧪 Adding or updating tests

## 🧪 How to test
- Steps to reproduce and validate
- Include sample data/fixtures if relevant

## API
- [ ] OpenAPI updated (if endpoints changed)
- [ ] Contract tests added/updated
- [ ] Backward compatible changes confirmed

## 📱 Frontend Checklist (if applicable)
- [ ] Component structure follows feature-sliced
- [ ] Types strict; no ts-ignore without justification
- [ ] Accessibility checked (labels, roles, keyboard)
- [ ] Performance considerations (memo, virtualization)
- [ ] Screenshots / video attached

## 🔧 Backend Checklist (if applicable)
- [ ] DTOs only in controllers; entities not exposed
- [ ] Validation annotations present; error schema returned
- [ ] Transactions defined; idempotency considered where needed
- [ ] Migrations added; indexes considered; tests updated
- [ ] Logging includes traceId; no PII

## 📸 Screenshots (if applicable)
Add screenshots or GIFs to demonstrate the changes.

## 🔗 Related PRs
List any related pull requests.

## 📝 Additional Notes
Any additional information that reviewers should know.

## ✅ Review Checklist
- [ ] PR links to a Jira issue and uses correct title format
- [ ] Branch named feature/<PROJECTKEY>-<issue-number>-<slug>
- [ ] Conventional commits used; Smart Commit applied if appropriate
- [ ] Unit/integration/E2E tests added/updated; coverage maintained
- [ ] OpenAPI/specs updated
- [ ] Lint/format/typecheck pass
- [ ] Security review done if touching auth/data
- [ ] Docs updated (README/ADRs)
- [ ] No merge conflicts; target branch up-to-date

---
Co-authored by Augment Code
