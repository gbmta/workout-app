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

### 4. Target section in Add Exercise is confusing — UX redesign
Three stacked Steppers (Sets / Rep range low / Rep range high) plus a Bodyweight
toggle feels disjointed and slow to use (lots of individual +/- taps for e.g. 15 reps).
Consider a more compact layout — maybe inline number fields like the workout logger's
`SetRow` uses, or a combined sets×reps control — rather than three separate stepper
rows. No firm design yet; worth a quick sketch/discussion before building.

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

**#1, #2 and #3 are done.** What's left is the two design conversations and one polish
item. **#4** and **#5** are genuine discussions, not quick fixes — good candidates for a
"let's talk through it" opening rather than diving into code; #4 now only has to change
`ExerciseTargetFields`, which both the add and edit sheets share. **#6** whenever there's
spare time at the end.
