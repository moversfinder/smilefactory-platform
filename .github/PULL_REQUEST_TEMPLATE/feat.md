---
name: Feature PR
about: Feature changes
---

# PR Title

Format: <PROJECTKEY>-<issue-number>: feat(scope): short description
Example: SF-123: feat(community): add tab registry

## Jira
- Issue: SF-123
- Link: https://your-jira-domain/browse/SF-123

## Summary
- What is changing and why?
- User types affected (if any):
- Community tabs affected (if any):

## How to test
- Steps to reproduce and validate
- Include sample data/fixtures if relevant

## API
- [ ] OpenAPI updated (if endpoints changed)
- [ ] Contract tests added/updated
- [ ] Backward compatible changes confirmed

## Frontend
- [ ] Feature-sliced structure followed
- [ ] Strict types; no ts-ignore without justification
- [ ] Accessibility checked (labels, roles, keyboard)
- [ ] Performance considerations (memo, virtualization)

## Backend
- [ ] DTOs only in controllers; validation annotations present
- [ ] Standard error schema returned
- [ ] Transactions defined where needed; idempotency considered
- [ ] Migrations/indexes updated if necessary

## Cross-cutting
- [ ] Logging includes traceId; no PII
- [ ] Security review (authZ/authN, data exposure)

## Checklist
- [ ] Unit/integration/E2E tests added/updated
- [ ] Lint/format/typecheck pass
- [ ] Docs updated (README/ADRs)
- [ ] Branch named `feature/<PROJECTKEY>-<issue-number>-<slug>`
- [ ] Smart Commit used if appropriate (e.g., `SF-123 #comment ...`)

---
Co-authored by Augment Code
