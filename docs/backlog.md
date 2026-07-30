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
ranges. Everything's staged in git but **not committed** — there's a large pile of
uncommitted work; consider committing before starting new changes.

## Backlog items, roughly in priority order

### 1. Search doesn't match muscle/category tags — bug, quick fix
In `AddExerciseEntryView.matches`, search only filters `exercise.name`. Searching
"chest" should also surface exercises tagged `.chest` even if the name doesn't contain
"chest" (e.g. "Barbell Bench Press"). Fix: also match against
`exercise.primaryMuscleGroups.map(\.displayName)` and
`exercise.categories.map(\.displayName)`.

### 2. Can't edit an exercise's sets/reps/target from the template screen — missing feature
Tapping an exercise row in `TemplateDetailView` does nothing. There's no way to change
targetSets/repRangeLow/repRangeHigh/isBodyweight for an already-added exercise — only
add, delete, and edit notes exist. Expectation: tapping the row (or a dedicated edit
affordance) opens something like `AddExerciseEntryView` pre-filled, saving via a new
`WorkoutStore.updateExercise(...)` that mutates the entry in place without touching
`loggedWeights`/`loggedReps`/`notes`. This is a real CRUD gap (Add + Delete exist,
Update doesn't, aside from notes).

### 3. Bodyweight toggle bug — needs repro
User report: "the bodyweight slider option doesn't turn off when you turn it on."
Wording is ambiguous — could mean (a) toggling doesn't visually respond, (b) it turns
on but can't be turned back off, or (c) something resets it. Hypothesis to check first:
in `AddExerciseEntryView.select(_:)`, tapping a catalog exercise sets
`isBodyweight = exercise.defaultsToBodyweight` — if a user manually overrides the
toggle and then taps any exercise row again (even the same one), it silently resets.
Reproduce in simulator before fixing blind.

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

Start with **#1 (search fix)** — smallest, clearest, no design decisions needed.
Then **#2 (edit exercise)** — biggest functional gap, but needs one design call: sheet
reusing `AddExerciseEntryView` vs. a dedicated lighter-weight edit view. Then **#3**
once reproduced. **#4** and **#5** are genuine design discussions, not quick fixes —
good candidates for a "let's talk through it" opening rather than diving into code.
**#6** whenever there's spare time at the end.
