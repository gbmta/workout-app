# CLAUDE.md

Native iOS workout app (SwiftUI, iOS 17+). Local-first: all data persists to JSON in the
app's Documents directory. An AWS backend (Cognito + API Gateway/Lambda + RDS Postgres)
is planned but **not started** — see README "Phased plan".

- **What to build next:** `docs/backlog.md` — read this first, it's the live task list.
- **Design system rationale:** `docs/design-overhaul-plan.md` (phases 1–5 all shipped).

## Build & run

`brew` and `xcodegen` are **not on the non-interactive shell PATH** — always call
xcodegen by absolute path:

```sh
/opt/homebrew/bin/xcodegen generate    # REQUIRED after adding/removing/renaming any source file
xcodebuild -project WorkoutApp.xcodeproj -scheme WorkoutApp \
  -destination 'id=6F66354F-57D1-4F4E-9701-5A535EEA9987' build
```

That UDID is the "iPhone 17" simulator. If it's stale:
`xcrun simctl list devices available | grep iPhone`

Built app lands at:
`~/Library/Developer/Xcode/DerivedData/WorkoutApp-*/Build/Products/Debug-iphonesimulator/WorkoutApp.app`

Run it with the iOS Simulator MCP: `attach` first (opens the panel for the user), then
`launch` with that .app path, then `screenshot` to verify. Filter noisy build output with
`| grep -E "(BUILD|error:)"`.

`WorkoutApp.xcodeproj` is **generated and gitignored** — never hand-edit it; edit
`project.yml` instead.

### Resetting app data

Persisted JSON survives reinstalls of the same bundle id. To force seed data to reload:

```sh
xcrun simctl uninstall <UDID> com.gabrielmota.workoutapp
```

Do this only when needed, and warn the user first — it deletes their real templates and
logged sets in the simulator.

## Architecture

```
Sources/WorkoutApp/
  Models/    Exercise, ExerciseCategory, MuscleGroup, WorkoutTemplate,
             WorkoutSession, SetLog, HypertrophyVolumeGuideline
  Data/      SeedExercises (50-exercise catalog), SeedTemplates (user's real
             Push/Pull/Legs), WorkoutStore (single source of truth)
  Views/     Theme + three tabs: Templates, Workout (live logging), Volume
```

`WorkoutStore` is an `@MainActor ObservableObject` injected via `.environmentObject`,
persisting four files (`workout_templates.json`, `active_session.json`,
`set_logs.json`, `favorite_exercises.json`). It's the seam where the future backend swaps in — keep views free of
persistence logic.

## Conventions

- **All colors/spacing come from `Theme.swift`.** Never introduce a raw `Color` or a
  system color in a view. Cards use `.themeCard()`, section headers `.sectionLabel()`.
  Accent is volt green; it means "done / on target / primary action" and nothing else.
- **Dark mode is the primary design target**, light must stay readable. Check both.
- **Exercise names are join keys.** Saved templates and set logs reference catalog
  exercises by `name`. Renaming a catalog entry orphans that history — add a new entry.
- **New persisted model fields must be `Optional`** so previously saved JSON still
  decodes. A non-optional added field throws `keyNotFound` and silently wipes user data
  (the loader falls back to seeds on decode failure). See
  `ExerciseTemplateEntry.muscleGroups` / `resolvedMuscleGroups` for the pattern.
- **Verify in the simulator before claiming done.** Build success is not enough; take a
  screenshot. Clean up any test templates/exercises created while verifying.

## Standing product decisions

Don't re-litigate these without the user raising them:

- **Never fabricate influencer content.** The app has an `InfluencerTip` model for Sam
  Sulek / Chris Bumstead / Jeff Nippard, but tips are deliberately empty — inventing
  quotes and attributing them to real people is off the table. Real sourcing is a
  future task.
- **Volume counts primary muscles only.** Indirect work (triceps while benching) isn't
  credited. Deliberately conservative; don't "fix" it silently.
- **No error/warning state for missing history.** Unknown past weights/reps render as a
  dash. An earlier `needsConfirmation` amber-badge concept was removed by user request —
  don't reintroduce warnings for incomplete data.
- **Exercise demo media is an intentional placeholder** (`ExerciseMediaPlaceholderView`);
  there are no real assets and none should be invented.
- **Templates must always be complete enough to run** — every exercise carries a real
  sets/rep-range target.

## Git

Remote: `https://github.com/gbmta/workout-app` (public), `main` tracks `origin/main`.
Commit and push only when the user asks.
