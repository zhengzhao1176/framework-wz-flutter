# Architecture

> Condensed from [`task/01-scope-and-architecture.md`](../task/01-scope-and-architecture.md).

## Layers

```
presentation/   ── Widgets, screens
application/    ── Riverpod providers, controllers (state)
domain/         ── Pure models + abstract repositories
data/           ── Concrete repos (dio, storage)
core/           ── Cross-cutting (theme, router, network, storage, widgets)
```

UI never imports `data/` directly — it consumes providers from `application/`,
which depend on `domain/` interfaces. The concrete `data/` implementation is
injected once at `app/app.dart` boot.

## Key flows

### Login

```
LoginPage
  → LoginController.submit()
    → AuthRepository.login()
      → dio.post('/api/auth/login')
        → MockInterceptor (in mock mode)
          → reads assets/fixtures/auth/login_*.json
      → secure_storage.write(token)
      → prefs.setString(role)
    → AuthEvent.loggedIn
  → context.go('/dashboard')
```

### Tabs + navigation

The `AppShell` listens to `GoRouterState`. When the matched location changes,
it computes the leaf `MenuNode` via `pathTo()` and calls
`TabsController.open(...)`. Tabs persist to `shared_preferences` so they
survive cold starts.

### Mock vs production

`ApiConfig.useMock` (default `true` via `--dart-define=USE_MOCK=true`)
enables `MockInterceptor`. Toggle off and set `--dart-define=API_BASE_URL=...`
to hit a real backend with zero other changes.

## Testing strategy

See [`task/04-test-plan.md`](../task/04-test-plan.md).

- **Unit** — pure functions, controllers, repos with in-memory storage
- **Widget** — single page, fake repo via `ProviderScope.overrides`
- **Integration** — `integration_test/` boots the real app with in-memory stores
