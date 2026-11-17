# Conventions

Rules for everyone (people and agents) working on this codebase.

## Ownership

- A feature agent owns only `lib/features/<feature>/**` and
  `test/features/<feature>/**`.
- **Frozen files** (do not edit; ask for a change in your report instead):
  - `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `l10n.yaml`
  - `lib/main.dart`, `lib/app.dart`, `lib/core/**`
  - `lib/l10n/*.arb` (and `lib/l10n/generated/**`)
  - `lib/features/movies/domain/**`, `lib/features/movies/data/**`
    (unless the movies agent is explicitly told otherwise)
- New packages or ARB keys are **requested in your report**, never added.

## Wiring a feature

- DI: put registrations in `lib/features/<f>/<f>_injection.dart`
  (`void registerXDependencies(GetIt sl)`). It is already called from
  `core/di/injection.dart`.
  - Repositories / data sources: `registerLazySingleton`.
  - Cubits / Blocs: `registerFactory`, created by a `BlocProvider` in the page.
- Shared services available from `sl`: `Dio`, `Connectivity`,
  `MoviesRepository`, and the Hive boxes by name:
  `sl<Box<dynamic>>(instanceName: HiveBoxes.watchlist)`
  (`homeCache`, `settings` likewise). Boxes store JSON maps
  (`MovieModel.toJson()`), no type adapters.
- Routes: edit `lib/features/<f>/<f>_routes.dart`.
  `xBranch` = the tab's routes (inside the bottom navigation bar);
  `xRoutes` = full-screen routes above it. Paths/names are in
  `core/router/routes.dart`; build paths with `Routes.movieDetailsPath(id)`
  and `Routes.seeAllPath(category.name)`.
- `SettingsCubit` and `AuthCubit` are provided above `MaterialApp`, so any
  page can use `context.read<SettingsCubit>()` or check
  `context.read<AuthCubit>().state is AuthSignedIn`.
- Anything that uses Firebase needs a fallback for when it is not running
  (tests, desktop): `initDependencies` checks `Firebase.apps` once and
  passes the answer to the features (see `NoopAnalyticsService`,
  `UnavailableAuthRepository`, `NoUserCloudData`).

## Architecture

- Layers: `data` (models, data sources, repository impl) -> `domain`
  (entities, abstract repositories) -> `presentation` (cubit/bloc, pages,
  widgets). Presentation never imports `data`.
- Data sources **throw** `AppException`s (`core/error/exceptions.dart`).
- Repositories **never throw**: they return `Result<T>` =
  `Success(value)` or `Err(failure)` (`core/result/result.dart`).
- Cubits call repositories directly. Add a use case only when there is real
  logic to put in it.
- Show errors with `ErrorView(message: failure.message(l10n), onRetry: ...)`.

## State management

- Cubit/Bloc states are `sealed` classes + `equatable`, e.g.
  `sealed class HomeState` with `HomeLoading`, `HomeLoaded`, `HomeError`.
  Data-only state with no loading/error (like `SettingsState`) may be a
  single class with `copyWith`.
- Search uses a `Bloc` with `bloc_concurrency`'s `restartable()` plus a
  debounce; everything else uses `Cubit`.

## UI

- All user-facing text comes from `AppLocalizations.of(context)`
  (keys are prefixed by feature: `movies*`, `details*`, `search*`,
  `watchlist*`, `settings*`, `account*`, `auth*`, `common*`, `nav*`).
- RTL: use `EdgeInsetsDirectional`, `AlignmentDirectional`,
  `PositionedDirectional`, `start`/`end` (never `left`/`right`).
- Spacing from `AppSpacing`; colors from `Theme.of(context).colorScheme`.
- Images via `ImageUrl.poster/backdrop/profile(path)`, which return `null`
  when there is no image. Reuse `MoviePosterCard`, `ErrorView`,
  `EmptyView`, `OfflineBanner` from `core/widgets`.
- Hero tags must be unique per screen (e.g. `'trending-${movie.id}'`).

## Tests

- No network in tests: mock with `mocktail`, test blocs with `bloc_test`.
- JSON fixtures live in `test/fixtures/`, read with `jsonFixture('x.json')`.
- Mirror the `lib/` path: `lib/features/x/a/b.dart` ->
  `test/features/x/a/b_test.dart`.

## Code generation

- `json_serializable` output (`*.g.dart`) and gen-l10n output
  (`lib/l10n/generated/`) **are committed**, so a fresh clone builds without
  running generators. After changing a model run
  `dart run build_runner build -d` and commit the result.
- No `freezed`, `injectable`, `fpdart`, `envied` or the original `hive`.

## Secrets

- The TMDB read access token comes from `env.json` (gitignored):
  `flutter run --dart-define-from-file=env.json`.
  `env.example.json` shows the format. Never commit a token.

## Before you hand off

```
dart run build_runner build -d
dart format --set-exit-if-changed lib test
flutter analyze        # must print "No issues found!"
flutter test           # all green
```

Commits: small, conventional (`feat:`, `fix:`, `test:`, `chore:`, `docs:`).
