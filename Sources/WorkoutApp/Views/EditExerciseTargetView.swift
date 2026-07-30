import SwiftUI

/// Edits an already-added exercise's target sets and rep range. Which exercise the
/// entry *is* stays fixed — the name joins the entry to its logged history — so this
/// sheet deliberately has no catalog picker, unlike `AddExerciseEntryView`.
struct EditExerciseTargetView: View {
    let templateID: WorkoutTemplate.ID
    let entry: ExerciseTemplateEntry

    @EnvironmentObject private var store: WorkoutStore
    @Environment(\.dismiss) private var dismiss

    @State private var targetSets: Int
    @State private var repRangeLow: Int
    @State private var repRangeHigh: Int
    @State private var isBodyweight: Bool

    init(templateID: WorkoutTemplate.ID, entry: ExerciseTemplateEntry) {
        self.templateID = templateID
        self.entry = entry
        _targetSets = State(initialValue: entry.targetSets)
        _repRangeLow = State(initialValue: entry.repRangeLow)
        _repRangeHigh = State(initialValue: entry.repRangeHigh)
        _isBodyweight = State(initialValue: entry.isBodyweight)
    }

    private var isValid: Bool {
        ExerciseTargetFields.isValidRange(low: repRangeLow, high: repRangeHigh)
    }

    var body: some View {
        NavigationStack {
            List {
                ExerciseTargetFields(
                    targetSets: $targetSets,
                    repRangeLow: $repRangeLow,
                    repRangeHigh: $repRangeHigh,
                    isBodyweight: $isBodyweight
                )

                if !entry.resolvedMuscleGroups.isEmpty {
                    Section {
                        Text(entry.resolvedMuscleGroups.map(\.displayName).joined(separator: " · "))
                            .foregroundStyle(Theme.textSecondary)
                            .listRowBackground(Theme.surface)
                    } header: {
                        Text("Muscles worked")
                    } footer: {
                        Text("Set when the exercise was added. Remove and re-add it to change this.")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
            .navigationTitle(entry.exerciseName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(!isValid)
                }
            }
        }
    }

    private func save() {
        store.updateExercise(
            entry.id,
            in: templateID,
            targetSets: targetSets,
            repRangeLow: repRangeLow,
            repRangeHigh: repRangeHigh,
            isBodyweight: isBodyweight
        )
        dismiss()
    }
}

#Preview {
    EditExerciseTargetView(templateID: SeedTemplates.push.id, entry: SeedTemplates.push.exercises[0])
        .environmentObject(WorkoutStore())
}
