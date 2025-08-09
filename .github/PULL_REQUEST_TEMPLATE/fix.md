---
name: Bugfix PR
about: Bug fixes and hotfixes
---

# PR Title

Format: <PROJECTKEY>-<issue-number>: fix(scope): short description
Example: SF-321: fix(auth): handle token refresh race

## Jira
- Issue: SF-321
- Link: https://your-jira-domain/browse/SF-321

## Summary
- Root cause
- Fix approach
- Risk and rollback plan

## How to test
- Repro steps and expected outcome
- Edge cases covered

## Checklist
- [ ] Unit/Integration tests added/updated
- [ ] Regression test added if applicable
- [ ] No breaking API changes
- [ ] Branch named `fix/<PROJECTKEY>-<issue-number>-<slug>`

---
Co-authored by Augment Code
