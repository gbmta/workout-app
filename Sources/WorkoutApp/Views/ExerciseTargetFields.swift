import SwiftUI

/// Which of the target fields has the keyboard. Owned by `ExerciseTargetFields` so the
/// three fields share one focus and therefore one keyboard toolbar.
private enum TargetField: Hashable {
    case sets
    case repRangeLow
    case repRangeHigh
}

/// The sets / rep-range / bodyweight controls, shared by the add and edit flows so
/// the two can't drift apart.
///
/// Tap-to-type fields rather than steppers: reaching 15 reps used to be seven taps on
/// a `Stepper`. Styling and keyboard both follow `SetRow` in `ActiveWorkoutView`, the
/// app's existing "type a number" idiom. Sets and reps are `Int`, so a typed decimal
/// rounds to the nearest whole number on commit rather than the "." being a dead key.
struct ExerciseTargetFields: View {
    @Binding var targetSets: Int
    @Binding var repRangeLow: Int
    @Binding var repRangeHigh: Int
    @Binding var isBodyweight: Bool

    @FocusState private var focused: TargetField?

    /// Rep range is only coherent low-to-high; callers disable their save action on this.
    static func isValidRange(low: Int, high: Int) -> Bool {
        low <= high
    }

    var body: some View {
        Section {
            HStack {
                Text("Sets")
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                NumberField(
                    value: $targetSets,
                    range: 1...10,
                    field: .sets,
                    focused: $focused,
                    accessibilityLabel: "Sets"
                )
            }

            HStack {
                Text("Reps")
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                NumberField(
                    value: $repRangeLow,
                    range: 1...50,
                    field: .repRangeLow,
                    focused: $focused,
                    accessibilityLabel: "Rep range low"
                )
                Text("–")
                    .foregroundStyle(Theme.textSecondary)
                NumberField(
                    value: $repRangeHigh,
                    range: 1...50,
                    field: .repRangeHigh,
                    focused: $focused,
                    accessibilityLabel: "Rep range high"
                )
            }

            Toggle("Bodyweight", isOn: $isBodyweight)
                // Declared on one row on purpose: `.toolbar` on the enclosing Section is
                // applied to every row, which stacks up a Done button per row.
                // .decimalPad has no return key, so the user needs this way out.
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") { focused = nil }
                    }
                }
        } header: {
            Text("Target")
        } footer: {
            if !Self.isValidRange(low: repRangeLow, high: repRangeHigh) {
                Text("The low end of the rep range can't be above the high end.")
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .listRowBackground(Theme.surface)
    }
}

/// A whole-number field that keeps its own draft text so partial input ("1" on the way
/// to "15") doesn't fight the bound value, clamping into `range` when focus leaves.
private struct NumberField: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let field: TargetField
    @FocusState.Binding var focused: TargetField?
    let accessibilityLabel: String

    @State private var text = ""

    private var hasFocus: Bool { focused == field }

    var body: some View {
        // Placeholder carries the current value, so an empty focused field still reads
        // as "8" rather than as blank — the same trick SetRow uses for last session's
        // numbers.
        TextField(String(value), text: $text)
            .font(Theme.numberFont(20))
            .monospacedDigit()
            .multilineTextAlignment(.center)
            .keyboardType(.decimalPad)
            .focused($focused, equals: field)
            .frame(width: 68, height: 44)
            .background(Theme.surfaceRaised)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(hasFocus ? Theme.accent.opacity(0.6) : .clear, lineWidth: 1.5)
            )
            .accessibilityLabel(accessibilityLabel)
            .onAppear { text = String(value) }
            .onChange(of: text) { _, newText in
                // Belt and braces next to .decimalPad: a hardware or dictation keyboard
                // can still deliver anything.
                let cleaned = Self.sanitized(newText)
                if cleaned != newText {
                    text = cleaned
                    return
                }
                // Track live so the range warning and the Save button keep up with
                // typing, but only for in-range values — clamping waits for blur so a
                // digit can be deleted mid-edit.
                if let parsed = Self.wholeNumber(from: cleaned), range.contains(parsed) {
                    value = parsed
                }
            }
            .onChange(of: focused) { _, newFocus in
                if newFocus == field {
                    // Start empty so the first digit replaces the old value instead of
                    // inserting next to it — tapping into "10" and typing 15 otherwise
                    // leaves you with 1510, since the caret lands where you tapped.
                    text = ""
                } else {
                    commit()
                }
            }
            .onChange(of: value) { _, newValue in
                if !hasFocus { text = String(newValue) }
            }
    }

    /// Leaving the field empty keeps the previous value rather than inventing a 0 or 1.
    private func commit() {
        let entered = Self.wholeNumber(from: text) ?? value
        let clamped = min(max(entered, range.lowerBound), range.upperBound)
        value = clamped
        text = String(clamped)
    }

    /// Digits plus at most one leading-digit-anchored decimal separator. Either separator
    /// is accepted so a comma-locale keyboard works too.
    private static func sanitized(_ input: String) -> String {
        var result = ""
        var hasSeparator = false
        for character in input {
            if character.isNumber {
                result.append(character)
            } else if isSeparator(character), !hasSeparator, !result.isEmpty {
                hasSeparator = true
                result.append(character)
            }
        }
        return result
    }

    /// Sets and reps are whole numbers in the model, so a typed decimal rounds to the
    /// nearest one — 8.6 reps becomes 9 rather than being silently dropped.
    private static func wholeNumber(from input: String) -> Int? {
        let normalized = String(input.map { isSeparator($0) ? "." : $0 })
        guard let value = Double(normalized), value.isFinite else { return nil }
        return Int(value.rounded())
    }

    private static func isSeparator(_ character: Character) -> Bool {
        character == "." || character == ","
    }
}
