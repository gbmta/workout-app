# Backlog

The live task list. Read this first, then just say which item to start on — no need to
re-explain the app, it's all below. When an item ships, drop it to the "Shipped" log at
the bottom (full rationale stays in git history).

## Current state (context for a fresh session)

SwiftUI app, dark-first volt-green theme (`Theme.swift`). Three tabs: Templates
(browse/build routines, edit an exercise's target inline), Workout (live session logging,
swipe between exercises, an animated motion diagram per exercise), Volume (weekly
muscle-group set counts vs. hypertrophy ranges). 50-exercise tagged catalog in
`SeedExercises.swift`; every catalog exercise now has an animated diagram (`ExercisePoses`
→ `ExerciseMotionDiagramView`). Templates show a volume summary card projecting logged
sets + this template against weekly ranges. All committed on `main`.

## Open items, roughly in priority order

### 1. Volume zone coloring isn't self-explanatory — education/UX
Template summary card and Volume tab both show a range like "6 of 6–12 · on target"
with color coding, but a user who doesn't know the hypertrophy-research backstory
(why 6–12, why weekly, why per-muscle) has no way to learn it from the UI. Needs some
kind of lightweight explainer — an info button/tooltip, a one-time card, or reworded
labels — so the color-coding is trustworthy rather than just asserted.
**Needs a call from you:** the tone — how much science to surface vs. keep it simple.
No firm design yet.

### 2. Keypad doesn't appear when editing a target field — bug, needs repro on device
Reported 2026-07-30 editing Incline Smith Machine Press: tapping a Sets/Reps field
doesn't pop the number keypad. In the simulator the field clearly *focuses* — accent
ring, blinking cursor, and the keyboard "Done" accessory bar shows — but the on-screen
keys don't draw. That signature points at the sim's hardware-keyboard setting
(`hw=Automatic`, `HardwareKeyboardLastSeen`) suppressing the software keyboard, i.e. a
simulator artifact rather than app code.
**Needs you:** repro on a physical device before assuming that. If it reproduces on
device, suspect the `.focused`/`FocusState` wiring in `ExerciseTargetFields` or a
responder conflict with the `.onTapGesture` row selection added in the multi-select
change. Related tooling note: [[simulator-toggle-taps]] — sim input has already faked one
"app bug" this project.

### 3. Muscle icon on the exercise progress capsules — nice-to-have polish
In `ActiveWorkoutView`, the row of capsules at the top (tap to jump exercises) only
shows fill color for logged/current/untouched. Idea: show a small muscle-group icon
per capsule (reuse the SF Symbol mapping already written for `VolumeTrackerView`) so
you can see at a glance which muscle each exercise/position hits. Low priority polish;
no decision needed from you.

## Shipped (2026-07-30)

- **Search matches muscle/category tags, not just names** — `AddExerciseEntryView`.
- **Edit an exercise's sets/reps/target inline from the template screen** — `EditExerciseTargetView`.
- **Bodyweight toggle no longer snaps back on** for `defaultsToBodyweight` exercises — `AddExerciseEntryView.select`.
- **Add-Exercise target section: tap-to-type number fields** replace the steppers — `ExerciseTargetFields`.
- **Animated exercise motion diagrams for all 50 exercises** — `ExerciseMotionDiagramView` + `ExercisePoses` (see the standing decision in `CLAUDE.md`).

Full rationale and implementation gotchas for each live in this file's earlier git revisions.
