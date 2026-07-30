# Workout App

Native iOS (SwiftUI) workout logging app with an AWS backend, built as a learning project.

## Status

Local scaffold only — no `.xcodeproj` is committed (it's generated, see below), and no
AWS resources exist yet. `git init` and AWS account setup are still pending on this
machine getting Xcode / Command Line Tools installed.

## Generating the Xcode project

The `.xcodeproj` isn't hand-written or committed — it's generated from `project.yml`
using [XcodeGen](https://github.com/yonaskolb/XcodeGen), so the project structure stays
in plain text and diffable in git instead of an opaque pbxproj blob.

Once Xcode / Command Line Tools are installed:

```sh
# install Homebrew if you don't have it: https://brew.sh
brew install xcodegen
xcodegen generate
open WorkoutApp.xcodeproj
```

Re-run `xcodegen generate` any time `project.yml` or the `Sources/` folder structure
changes.

## Project structure

```
Sources/WorkoutApp/
  App/            App entry point
  Models/         Exercise, WorkoutTemplate, SetLog, MuscleGroup, volume guidelines
  Data/           Seed data — your exercise catalog and 3 workout templates
  Views/          SwiftUI views
project.yml       XcodeGen spec (source of truth for the Xcode project)
```

## Exercise library

`Sources/WorkoutApp/Data/SeedExercises.swift` holds 50 exercises, each tagged with:

- **categories** (`push` / `pull` / `legs` / `core`) — drives the filter in the exercise
  picker. Creating a template named "Push" auto-selects the push category, so only push
  exercises are listed. Exercises can carry more than one category (core work is also
  tagged `legs`, since it usually rides along on leg day).
- **primary muscle groups** — every per-muscle set count in the app comes from these.
  Indirect work (triceps during pressing, biceps during rows) is deliberately *not*
  counted, so numbers stay conservative rather than flattering.
- **bodyweight default** — picking Pull Ups or Dips pre-flips the bodyweight toggle.

**To add an exercise, add one line to `catalog`.** Nothing else needs changing; the
picker, filters, and volume math pick it up automatically.

Exercise **names are the join key** used by saved templates and set logs. Renaming an
existing entry orphans that history — add a new entry instead.

Custom exercises (not in the catalog) are supported and require choosing their muscles
at add time, which is what lets them count toward weekly volume.

## Notes on seeded data

Some historical set values were cut off or blank in the source notes-app photos.
Unknown history is stored as `nil` in `Sources/WorkoutApp/Data/SeedTemplates.swift`
and rendered as a dash — it's treated as plain missing history, not an error state.
Two targets weren't specified in the source notes and were defaulted: Cable Push
Down (3×10–15) and Hammer Curls (2×12–15, sets from the original note). Logging a
real session overwrites history with actual numbers.

## Phased plan

1. **Local scaffold** — SwiftUI skeleton, models, seeded templates (this step).
2. **AWS account + IAM setup** — root account, non-root admin IAM user, billing alarm.
3. **Backend architecture** — Cognito (auth) + API Gateway/Lambda (API) + RDS Postgres
   (data), deployed via infrastructure-as-code.
4. **iOS ↔ backend integration** — login flow, workout CRUD synced to the backend.
5. **Volume tracker** — wire logged sets into the weekly per-muscle-group tracker
   against the hypertrophy volume goals already modeled in `HypertrophyVolumeGuideline`.
6. **Influencer tips content** — Sam Sulek / Chris Bumstead / Jeff Nippard cues per
   exercise, sourced properly rather than invented (see note in `InfluencerTip.swift`).
7. **(Post-v1)** Macro/calorie tracking — data model already leaves room for this
   (see `SetLog.swift`), not built in v1.

## AWS architecture decision

Auth: **Cognito**. API: **API Gateway + Lambda**. Database: **RDS Postgres**.

Chosen for the most transferable AWS learning path and because the data (users →
templates → exercises → sets, aggregated into weekly volume per body part) is
naturally relational.
