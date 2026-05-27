# Contributing

## Branch / PR

- `main` is protected. All work goes through PRs.
- Branch names: `feat/<scope>`, `fix/<scope>`, `chore/<scope>`.
- PR title format: `<type>(<scope>): <imperative summary>`.
  Example: `feat(table): add CSV export`.

## Commit messages

Conventional Commits:

```
feat(charts): add gauge chart
fix(auth): clear secure storage on logout
test(table): cover pagination edge case
docs(test-guide): add coverage targets
```

## Before opening a PR

```bash
dart format .
flutter analyze            # must be zero warnings
flutter test --coverage    # must be green
```

Reference a `task_id` and one or more `TC-…` IDs in the PR body.

## Code style

- No `print` — use a real logger when needed.
- No `dynamic` unless interop forces it.
- Public widgets must have a `key` if used in tests (`Key('feature.element')`).
- Internal widgets use `_PrivateName` and stay file-private.
- Don't introduce new abstractions for a single caller.

## Adding deps

- Argue for it in the PR (size, license, maintenance).
- Pin a version.
- Update `task/06-risks-and-tooling.md` if it changes the toolchain story.
