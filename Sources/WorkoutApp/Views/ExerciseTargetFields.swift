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
/// a `Stepper`. The field styling follows `SetRow` in `ActiveWorkoutView`, which is
/// already the app's "type a number" idiom — but on `.numberPad`, since sets and reps
/// are whole numbers (`SetRow` needs `.decimalPad` only because weight isn't).
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
                // .numberPad has no return key, so the user needs this way out.
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
            .keyboardType(.numberPad)
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
                // Belt and braces next to .numberPad: a hardware or dictation keyboard
                // can still deliver anything.
                let digits = newText.filter(\.isNumber)
                if digits != newText {
                    text = digits
                    return
                }
                // Track live so the range warning and the Save button keep up with
                // typing, but only for in-range values — clamping waits for blur so a
                // digit can be deleted mid-edit.
                if let parsed = Int(digits), range.contains(parsed) {
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
        let clamped = min(max(Int(text) ?? value, range.lowerBound), range.upperBound)
        value = clamped
        text = String(clamped)
    }
}
