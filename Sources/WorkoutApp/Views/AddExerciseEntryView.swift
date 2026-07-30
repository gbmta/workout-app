import SwiftUI

struct AddExerciseEntryView: View {
    let templateID: WorkoutTemplate.ID

    @EnvironmentObject private var store: WorkoutStore
    @Environment(\.dismiss) private var dismiss

    @State private var selectedExercise: Exercise?
    @State private var customName = ""
    @State private var customMuscles: Set<MuscleGroup> = []
    @State private var isAddingCustom = false
    @State private var search = ""
    @State private var categoryFilter: ExerciseCategory?
    @State private var didApplyTemplateCategory = false

    @State private var targetSets = 3
    @State private var repRangeLow = 8
    @State private var repRangeHigh = 12
    @State private var isBodyweight = false

    private var template: WorkoutTemplate? {
        store.templates.first { $0.id == templateID }
    }

    private var matches: [Exercise] {
        let base = SeedExercises.catalog(for: categoryFilter)
        let query = search.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return base }
        return base.filter { matches($0, query: query) }
    }

    /// Searching "chest" should surface Barbell Bench Press, so the query is matched
    /// against the exercise's muscle and category tags as well as its name.
    private func matches(_ exercise: Exercise, query: String) -> Bool {
        let haystack = [exercise.name]
            + exercise.primaryMuscleGroups.map(\.displayName)
            + exercise.categories.map(\.displayName)
        return haystack.contains { $0.localizedCaseInsensitiveContains(query) }
    }

    private var resolvedName: String {
        isAddingCustom ? customName.trimmingCharacters(in: .whitespaces) : (selectedExercise?.name ?? "")
    }

    private var resolvedMuscles: [MuscleGroup] {
        if isAddingCustom {
            return MuscleGroup.allCases.filter { customMuscles.contains($0) }
        }
        return selectedExercise?.primaryMuscleGroups ?? []
    }

    private var isValid: Bool {
        !resolvedName.isEmpty
            && !resolvedMuscles.isEmpty
            && ExerciseTargetFields.isValidRange(low: repRangeLow, high: repRangeHigh)
    }

    var body: some View {
        NavigationStack {
            List {
                if isAddingCustom {
                    customExerciseSection
                } else {
                    catalogSection
                }
                targetSection
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
            .searchable(text: $search, prompt: "Search \(SeedExercises.catalog.count) exercises")
            .navigationTitle(isAddingCustom ? "Custom Exercise" : "Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: addEntry)
                        .disabled(!isValid)
                }
            }
            .onAppear(perform: applyTemplateCategoryOnce)
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var catalogSection: some View {
        Section {
            Picker("Type", selection: $categoryFilter) {
                Text("All").tag(ExerciseCategory?.none)
                ForEach(ExerciseCategory.allCases) { option in
                    Text(option.displayName).tag(ExerciseCategory?.some(option))
                }
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.clear)
        }

        Section {
            if matches.isEmpty {
                Text("No exercises match.")
                    .foregroundStyle(Theme.textSecondary)
            }
            ForEach(matches) { exercise in
                Button {
                    select(exercise)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(exercise.name)
                                .foregroundStyle(Theme.textPrimary)
                            Text(exercise.primaryMuscleGroups.map(\.displayName).joined(separator: " · "))
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        Spacer()
                        if selectedExercise?.id == exercise.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Theme.accent)
                        }
                    }
                }
                .listRowBackground(Theme.surface)
            }
        } header: {
            Text("\(matches.count) exercise\(matches.count == 1 ? "" : "s")")
        } footer: {
            Button("Add a custom exercise instead") {
                isAddingCustom = true
                selectedExercise = nil
            }
            .font(.footnote)
        }
    }

    @ViewBuilder
    private var customExerciseSection: some View {
        Section("Name") {
            TextField("Exercise name", text: $customName)
                .listRowBackground(Theme.surface)
        }

        Section {
            ForEach(MuscleGroup.allCases) { muscle in
                Button {
                    if customMuscles.contains(muscle) {
                        customMuscles.remove(muscle)
                    } else {
                        customMuscles.insert(muscle)
                    }
                } label: {
                    HStack {
                        Text(muscle.displayName)
                            .foregroundStyle(Theme.textPrimary)
                        Spacer()
                        if customMuscles.contains(muscle) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Theme.accent)
                        }
                    }
                }
                .listRowBackground(Theme.surface)
            }
        } header: {
            Text("Muscles worked")
        } footer: {
            Text("Required — this is what credits the exercise toward your weekly volume.")
        }

        Section {
            Button("Pick from the exercise library instead") {
                isAddingCustom = false
                customName = ""
                customMuscles = []
            }
            .font(.footnote)
            .listRowBackground(Color.clear)
        }
    }

    @ViewBuilder
    private var targetSection: some View {
        ExerciseTargetFields(
            targetSets: $targetSets,
            repRangeLow: $repRangeLow,
            repRangeHigh: $repRangeHigh,
            isBodyweight: $isBodyweight
        )
    }

    // MARK: - Actions

    private func applyTemplateCategoryOnce() {
        guard !didApplyTemplateCategory else { return }
        didApplyTemplateCategory = true
        categoryFilter = template?.category
    }

    private func select(_ exercise: Exercise) {
        selectedExercise = exercise
        isBodyweight = exercise.defaultsToBodyweight
    }

    private func addEntry() {
        let entry = ExerciseTemplateEntry(
            exerciseName: resolvedName,
            targetSets: targetSets,
            repRangeLow: repRangeLow,
            repRangeHigh: repRangeHigh,
            isBodyweight: isBodyweight,
            muscleGroups: resolvedMuscles
        )
        store.addExercise(entry, to: templateID)
        dismiss()
    }
}

#Preview {
    AddExerciseEntryView(templateID: SeedTemplates.push.id)
        .environmentObject(WorkoutStore())
}
