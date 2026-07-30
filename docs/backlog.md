# Backlog

Captured 2026-07-29, end of session, to pick up fresh next time without replaying the
whole conversation. Read this file, then just say which item to start on — no need to
re-explain the app, it's all below.

## Current state (context for a fresh session)

SwiftUI app, dark-first volt-green theme (`Theme.swift`). Three tabs: Templates
(browse/build routines), Workout (live session logging, swipe between exercises),
Volume (weekly muscle-group set counts vs. hypertrophy ranges). 50-exercise tagged
catalog in `SeedExercises.swift` (category + primary muscles per exercise). Templates
now show a volume summary card projecting logged sets + this template against weekly
ranges. All of that is committed on `main` now.

## Backlog items, roughly in priority order

### 1. ~~Search doesn't match muscle/category tags~~ — DONE 2026-07-30
`AddExerciseEntryView` now matches the query against the exercise's name, its
`primaryMuscleGroups` display names, and its `categories` display names. Verified in the
simulator: "chest" returns 9 exercises (was 1 — only "Machine Chest Press" matched by
name), "core" returns the 4 abs exercises, name search unaffected.

### 2. ~~Can't edit an exercise's sets/reps/target from the template screen~~ — DONE 2026-07-30
Tapping an exercise card in `TemplateDetailView` now opens `EditExerciseTargetView`, a
dedicated sheet (modeled on `EditExerciseNoteView`) with the target controls pre-filled.
It saves through `WorkoutStore.updateExercise(_:in:targetSets:repRangeLow:repRangeHigh:isBodyweight:)`,
which touches only those four fields — `loggedWeights`/`loggedReps`/`notes`/`muscleGroups`
are left alone.

Chose a dedicated sheet over reusing `AddExerciseEntryView` because that view is mostly
catalog picker, and `exerciseName` is the join key for logged history — an edit screen
must not be able to change it. The sheet shows the entry's muscles read-only with a note
to remove/re-add to change them.

Sets/reps/bodyweight controls now live in one shared `ExerciseTargetFields` used by both
the add and edit sheets, so **#4's redesign only has to be done once**.

### 3. ~~Bodyweight toggle bug~~ — DONE 2026-07-30
Reproduced, and the standing hypothesis was right: `AddExerciseEntryView.select(_:)`
unconditionally re-applied `exercise.defaultsToBodyweight`. Repro was: pick Dips (which
defaults to bodyweight, so the toggle turns itself on), turn it off, tap the Dips row
again — it snapped straight back on. Reading (b) of the report was the accurate one, and
it only bites on the six `defaultsToBodyweight: true` exercises, where the toggle starts
on and therefore looks un-turn-off-able.

Fix: `select(_:)` returns early when the tapped exercise is already selected, and seeds
`isBodyweight` from the catalog only until the user sets the toggle themselves — tracked
by `didOverrideBodyweight`, set from a write-through `Binding`. After a manual change,
the user's choice sticks for the rest of the sheet, even when switching to a different
bodyweight-default exercise. Catalog defaults still apply on a fresh sheet.

### 4. ~~Target section in Add Exercise is confusing~~ — DONE 2026-07-30
Replaced the three Steppers with tap-to-type number fields in `ExerciseTargetFields`,
following the `SetRow` idiom, keyboard included: `.decimalPad`, per user preference for
consistency with the workout logger. Layout is now `Sets [4]` / `Reps [8] – [10]` /
Bodyweight. Setting 15 reps went from 7 stepper taps to 3.

Details worth knowing before touching it again:
- **Focus clears the field**, with the current value left as the placeholder. Without
  that, the caret lands where you tapped and typing 15 into "10" gives 1510.
- **Empty on blur keeps the previous value**; out-of-range input clamps (99 → 50).
- **Typed decimals round to the nearest whole number on commit** (8.6 → 9). Sets and reps
  are `Int` in the model, so the `.` would otherwise be a dead key. A lone `.` is dropped
  and keeps the previous value. Both `.` and `,` are accepted for comma locales.
- **One keyboard toolbar `Done`**, declared on a single row on purpose — `.toolbar` on
  the enclosing `Section` is applied per row and stacks up one button per row.
  `.decimalPad` has no return key, so the button is load-bearing.
- Invalid ranges now say so in the section footer instead of only disabling Save.

Also fixed `Theme.surfaceRaised`, which was `0xFFFFFF` in light mode — identical to
`surface`, so every raised element (these fields, `SetRow`'s, the muscle chips) was
invisible against its card. Now `0xEDEDF0`.

### 5. Volume zone coloring isn't self-explanatory — education/UX
Template summary card and Volume tab both show a range like "6 of 6–12 · on target"
with color coding, but a user who doesn't know the hypertrophy-research backstory
(why 6–12, why weekly, why per-muscle) has no way to learn it from the UI. Needs some
kind of lightweight explainer — an info button/tooltip, a one-time card, or reworded
labels — so the color-coding is trustworthy rather than just asserted. No firm design
yet either; worth discussing tone (how much science to surface vs. keep it simple).

### 6. Muscle icon on the exercise progress capsules — nice-to-have, backlog
In `ActiveWorkoutView`, the row of capsules at the top (tap to jump exercises) only
shows fill color for logged/current/untouched. Idea: show a small muscle-group icon
per capsule (reuse the SF Symbol mapping already written for `VolumeTrackerView`) so
you can see at a glance which muscle each exercise/position hits. Low priority polish.

## Suggested order for next session

**#1–#4 are done.** Left: **#5** (explaining the volume zones) — still a genuine design
discussion, mostly about tone: how much hypertrophy-research detail to surface vs. keep it
simple. Then **#6** (muscle icons on the workout progress capsules) as polish.
