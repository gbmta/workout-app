import SwiftUI

/// The sets / rep-range / bodyweight controls, shared by the add and edit flows so
/// the two can't drift apart. Backlog #4 wants this layout redesigned — doing it here
/// changes both screens at once.
struct ExerciseTargetFields: View {
    @Binding var targetSets: Int
    @Binding var repRangeLow: Int
    @Binding var repRangeHigh: Int
    @Binding var isBodyweight: Bool

    /// Rep range is only coherent low-to-high; callers disable their save action on this.
    static func isValidRange(low: Int, high: Int) -> Bool {
        low <= high
    }

    var body: some View {
        Section("Target") {
            Stepper("Sets: \(targetSets)", value: $targetSets, in: 1...10)
            Stepper("Rep range low: \(repRangeLow)", value: $repRangeLow, in: 1...50)
            Stepper("Rep range high: \(repRangeHigh)", value: $repRangeHigh, in: 1...50)
            Toggle("Bodyweight", isOn: $isBodyweight)
        }
        .listRowBackground(Theme.surface)
    }
}
