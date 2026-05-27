# Test Guide

## Running

```bash
# Unit + widget
flutter test

# With coverage
flutter test --coverage

# A single file
flutter test test/unit/auth/auth_repository_test.dart

# Integration
flutter test integration_test/

# Update goldens after intentional UI change
flutter test --update-goldens
```

## Test IDs

Every test references an ID in [`task/04-test-plan.md`](../task/04-test-plan.md).
Naming: `TC-<MODULE>-<NNN>` for behavioral tests; `TG-<PAGE>-<NN>` for goldens;
`TE-<NN>` for E2E.

When adding a new test, **add the ID to the test plan first**. The test plan
is the spec.

## Conventions

- Helpers live in `test/helpers/`.
- Fakes (in-memory repos) preferred over `mocktail` when the surface is small.
- `MockInterceptor.fixtureLoader` lets tests load `assets/fixtures/...` from
  the filesystem without a Flutter binding.
- Widget tests never touch real network or secure storage. Always override
  providers via `ProviderScope.overrides`.

## Coverage targets

- `core/` and `features/*/domain|data` — **≥ 90%**
- `features/*/presentation` — **≥ 70%**
- Total — **≥ 80%**

## Adding a new feature — TDD loop

1. Write the test IDs into `task/04-test-plan.md` with Given/When/Then.
2. Write a test in `test/` that asserts the expected behavior.
3. Implement just enough to make it pass.
4. Refactor.
5. Repeat.
