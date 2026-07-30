# Design Overhaul Plan

Goal: take the app from "default SwiftUI tutorial" to a real training app. Dark-first,
one accent color, big numerals, and a one-tap set logger. This doc pre-makes every
taste decision so implementing agents don't have to invent any design judgment —
**do not deviate from tokens/specs here; if something is ambiguous, pick the simplest
option that compiles.**

Work through phases in order. Each phase must end with: `xcodegen generate` (only if
files were added/removed), a clean `xcodebuild` for the simulator, a launch via the
iOS Simulator MCP, and screenshots verifying the acceptance checklist. Keep the app
buildable at every phase boundary. Stage with `git add -A` after each phase (do not
commit unless asked).

Build command reference (device id may differ — list with `xcrun simctl list devices available`):

```
/opt/homebrew/bin/xcodegen generate
xcodebuild -project WorkoutApp.xcodeproj -scheme WorkoutApp -destination 'id=<SIM_UDID>' build
```

App binary lands in `~/Library/Developer/Xcode/DerivedData/WorkoutApp-*/Build/Products/Debug-iphonesimulator/WorkoutApp.app`.

---

## Phase 1 — Design system foundation (`Theme.swift`)

New file `Sources/WorkoutApp/Views/Theme.swift`. Everything below lives there.

### Color tokens

Use dynamic colors (dark is primary; light is derived, don't agonize over it):

| Token | Dark | Light | Use |
|---|---|---|---|
| `Theme.bg` | `#0D0D0F` | `#F4F4F6` | screen background |
| `Theme.surface` | `#1A1A1E` | `#FFFFFF` | cards, sheets |
| `Theme.surfaceRaised` | `#232329` | `#FFFFFF` | fields, chips on cards |
| `Theme.accent` | `#BFFF3C` | `#7BC618` | CTAs, logged sets, progress-in-zone |
| `Theme.onAccent` | `#0D0D0F` | `#FFFFFF` | text on accent |
| `Theme.textPrimary` | `#F5F5F7` | `#111113` | |
| `Theme.textSecondary` | `#9A9AA3` | `#6B6B74` | |
| `Theme.warn` | `#FBBF24` | `#B45309` | needs-confirmation, over-MRV |
| `Theme.danger` | `#F87171` | `#DC2626` | destructive |
| `Theme.zoneUnder` | `#5A5A64` | `#9CA3AF` | volume below min |

Implement as `enum Theme` with `static let` `Color`s built from
`Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: ...) : UIColor(hex: ...) })`
plus a small `UIColor(hex:)` init in the same file.

### Type & metrics

- `Theme.numberFont(_ size: CGFloat)` → `.system(size: size, weight: .semibold, design: .rounded)` + callers add `.monospacedDigit()`.
- Section labels: `.caption.weight(.semibold)`, uppercase, `.tracking(1.2)`, `textSecondary`.
- Spacing scale: 4 / 8 / 12 / 16 / 24 only. Corner radius: **14** cards, **10** fields/chips. Min tap target 44pt.
- `Theme.cardBackground()` — a `ViewModifier` (padding 16, `surface` fill, radius 14) applied via `.themeCard()` extension.

### Wiring

- `WorkoutAppApp.swift`: apply `.tint(Theme.accent)` and `.background(Theme.bg)` at root; set `.preferredColorScheme(nil)` (respect system).
- All three tabs: set list/scroll backgrounds to `Theme.bg` (`.scrollContentBackground(.hidden)` + `.background(Theme.bg)`).
- Kill the default system-blue links look: buttons that were bare `Text` links get restyled in later phases; here just confirm accent propagates.

**Accept:** app builds; all tabs show dark bg with volt accent in dark mode; light mode not broken (readable, no black-on-black).

---

## Phase 2 — Templates tab + template detail restyle

Files: `TemplatesListView.swift`, `TemplateDetailView.swift`.

1. **Fix pluralization** everywhere: `"\(n) exercise\(n == 1 ? "" : "s")"`. Same for "sets".
2. Template rows become cards (`.themeCard()`, `listRowSeparator` hidden, `listRowBackground(Color.clear)`): name in `.title3.bold()`, exercise count in `textSecondary`, and the warning becomes a **single compact badge** (`exclamationmark.circle.fill` + "Needs input", `Theme.warn`, caption) — not a full sentence.
3. **Kill the "?" walls.** In `TemplateDetailView`, replace the unlabeled weight/reps grid with one summary line per exercise: `Last: 70×10 · 70×8 · 70×8` (weight×reps pairs, `numberFont(15)`, textSecondary; bodyweight renders `BW×10`). Unknown set → `–` (en dash), never `?`. If nothing logged ever: `No history yet`.
4. The long orange confirmation paragraphs collapse to the compact warn badge; full `confirmationNote` text moves into the note editor sheet area (show it inside `EditExerciseNoteView` above the editor as caption text) — the list stays scannable.
5. "Add note"/"Edit note" links become a small trailing icon button (`note.text` SF symbol, textSecondary, 44pt target). A filled note shows the icon in accent.
6. "Start Workout" button: full-width, accent fill, `onAccent` bold label, radius 14, height 52. Keep placement.

**Accept:** no `?` anywhere on these screens; one-line history per exercise; warn state is one badge; grammar fixed; screenshots in both modes.

---

## Phase 3 — Active workout: the logger (biggest phase, split it)

Files: `ActiveWorkoutView.swift`, `WorkoutStore.swift` (one new method), `ExerciseMediaPlaceholderView.swift`.

### 3a. Layout & header

- Exercise name drops to `.title2.bold()`, single line, `minimumScaleFactor(0.7)`.
- Replace "Exercise 2 of 6" caption with a **segmented progress bar**: HStack of `session.exercises.count` capsules (height 4, spacing 4); filled `accent` for exercises with ≥1 logged set, `accent` at 50% opacity for current, `zoneUnder` otherwise. Tapping a segment calls `goToExercise` (min 44pt tap area via `.contentShape`).
- **Shrink the media placeholder**: `ExerciseMediaPlaceholderView` becomes a 56pt-tall HStack row (symbol + "Demo coming soon", surface bg, radius 10). It sits *below* the set logger, not above. Sets are the hero.
- Target line: `TARGET 4 × 8–10` in the section-label style.

### 3b. Set rows — the one-tap logger

Replace `SetRow` with:

```
[ 20pt set # ] [ ghost "70×10" prev ] [ weight field ] [ reps field ] [ ◯ log button ]
```

- Fields: `numberFont(22)`, `surfaceRaised` bg, radius 10, height 48, numeric keyboards (keep the existing String↔number bindings).
- **Log button** (the core interaction): 32pt circle, trailing.
  - Unlogged + row empty → tapping fills weight/reps from `previousWeights/previousReps[index]` (fallback: the nearest earlier logged row's values, else just marks logged with whatever is typed) via ONE new store method `logSet(exerciseIndex:setIndex:)`, then shows logged state.
  - Logged state: circle becomes `checkmark.circle.fill` in accent, row's fields tint accent border, trigger `UINotificationFeedbackGenerator().notificationOccurred(.success)`.
  - A set is "logged" when `reps != nil` (existing rule — the button is sugar over it, no new model field).
- "Add Set" becomes a full-width dashed-border button (surfaceRaised, radius 10, `plus` + "Add Set").
- Notes editor: keep, but restyle to `surfaceRaised`/radius 10 and move below media row. Placeholder overlay stays.

### 3c. Finish summary sheet

- "Finish" no longer instantly ends: it presents a sheet — `WorkoutSummaryView` (new file):
  - Big `checkmark.circle.fill` (accent, 64pt, `.symbolEffect(.bounce)` on appear).
  - `templateName`, duration (`startedAt` → now, formatted "48 min"), total logged sets, and per-muscle logged-set counts (reuse `SeedExercises.exercise(named:)` mapping).
  - One accent button "Done" → calls `store.finishSession()` and dismisses. "Keep training" text button cancels the sheet.
- Compute the summary from `activeSession` *before* calling `finishSession` (it nils the session).

**Accept:** one tap logs a "same as last time" set with haptic + visual state; progress capsules navigate; media row is compact and below sets; finish shows summary then returns to picker. Screenshot each state.

---

## Phase 4 — Volume tab zones

File: `VolumeTrackerView.swift`.

- Each muscle row: name + `12 / 10–20` (`numberFont(17)`) + custom bar (no stock `ProgressView`): 8pt-tall capsule track (`surfaceRaised`) with fill = `min(logged, max)/max`. Fill color: `zoneUnder` if `logged < min`, `accent` if within `min...max`, `warn` if `> max`.
- Under-min rows also show caption `"X to go"` in textSecondary.
- Header above list: `THIS WEEK` section label + caption "rolling last 7 days".
- Rows are cards; muscle name gets a small SF symbol prefix (single mapping in this file: chest `figure.arms.open`, back `figure.climbing`, shoulders `figure.boxing`, biceps/triceps `dumbbell`, quads/hamstrings/glutes `figure.walk`, calves `figure.stairs`, abs `figure.core.training` — literal exactness doesn't matter, consistency does).

**Accept:** zones visibly change color at boundaries (log fake sets to verify under/in-range at least); screenshots.

---

## Phase 5 — Polish pass

- **Animations:** `withAnimation(.spring(duration: 0.3))` on exercise switch; `.contentTransition(.numericText())` on volume numbers; `.animation` on set-row logged-state change. Nothing longer than 0.35s.
- **Haptics:** `.success` on set log (done in 3b) and workout finish; `UIImpactFeedbackGenerator(style: .light)` on exercise switch.
- **Empty states:** replace both `ContentUnavailableView` usages with themed versions (SF symbol in accent, one-line message, one CTA where sensible — e.g. Workout tab empty → "Pick a template to start" button that just switches `store.selectedTab = .templates`).
- **Dark/light audit:** screenshot every screen in both modes; fix any contrast failures (text on accent must always be `onAccent`).
- Fix any remaining bare-blue-text buttons missed in earlier phases.

**Accept:** full click-through in simulator both modes, no stock-blue strays, no layout overflow on iPhone SE-class width (test with `resize_window` mobile preset if using browser tools — or just the default sim).

---

## Engineering cleanups to fold in opportunistically (not blocking)

- `WorkoutStore.updateNotes(forExerciseNamed:)` matches by exercise *name* — breaks with duplicate names in one template. Prefer carrying the entry `id` into `SessionExercise` later; note it, don't redesign now.
- `TextEditor` placeholder is an overlay hack; acceptable, leave it.

## Explicitly out of scope (do not build)

Rest timer, real exercise media, influencer tips content, app icon, onboarding, AWS/backend anything.
