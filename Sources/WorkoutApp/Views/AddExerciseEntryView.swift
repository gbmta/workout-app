import SwiftUI

struct AddExerciseEntryView: View {
    let templateID: WorkoutTemplate.ID

    @EnvironmentObject private var store: WorkoutStore
    @Environment(\.dismiss) private var dismiss

    /// Selection order, so exercises land in the template in the order they were tapped.
    @State private var selectedExercises: [Exercise] = []
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
    @State private var didOverrideBodyweight = false

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

    private var customExerciseName: String {
        customName.trimmingCharacters(in: .whitespaces)
    }

    private var customExerciseMuscles: [MuscleGroup] {
        MuscleGroup.allCases.filter { customMuscles.contains($0) }
    }

    private func isSelected(_ exercise: Exercise) -> Bool {
        selectedExercises.contains { $0.id == exercise.id }
    }

    private var isValid: Bool {
        guard ExerciseTargetFields.isValidRange(low: repRangeLow, high: repRangeHigh) else { return false }
        if isAddingCustom {
            return !customExerciseName.isEmpty && !customExerciseMuscles.isEmpty
        }
        return !selectedExercises.isEmpty
    }

    private var addButtonTitle: String {
        selectedExercises.count > 1 && !isAddingCustom ? "Add \(selectedExercises.count)" : "Add"
    }

    /// What the Bodyweight toggle shows. Until the user sets it themselves it summarises
    /// the per-exercise catalog defaults, which is what `addEntry` will actually apply —
    /// so it only reads "on" when every selected exercise is a bodyweight movement.
    private var effectiveBodyweight: Bool {
        if didOverrideBodyweight || isAddingCustom { return isBodyweight }
        return !selectedExercises.isEmpty && selectedExercises.allSatisfy(\.defaultsToBodyweight)
    }

    private var targetNote: String? {
        guard !isAddingCustom, selectedExercises.count > 1 else { return nil }
        return "Applies to all \(selectedExercises.count). Bodyweight follows each exercise unless you set it here."
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
                    Button(addButtonTitle, action: addEntry)
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
                HStack(spacing: 0) {
                    // Selection is a tap gesture rather than a Button on purpose: a List
                    // row holding a single Button gets the *whole* row as that button's
                    // hit area, so the star overlapped it and one tap both selected the
                    // exercise and favorited it.
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(exercise.name)
                                .foregroundStyle(Theme.textPrimary)
                            Text(exercise.primaryMuscleGroups.map(\.displayName).joined(separator: " · "))
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        Spacer()
                        if isSelected(exercise) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Theme.accent)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { toggleSelection(exercise) }
                    .accessibilityAddTraits(isSelected(exercise) ? [.isButton, .isSelected] : .isButton)

                    favoriteButton(for: exercise)
                }
                .listRowBackground(Theme.surface)
            }
        } header: {
            HStack {
                Text("\(matches.count) exercise\(matches.count == 1 ? "" : "s")")
                if !selectedExercises.isEmpty {
                    Spacer()
                    Text("\(selectedExercises.count) selected")
                        .foregroundStyle(Theme.accent)
                }
            }
        } footer: {
            Button("Add a custom exercise instead") {
                isAddingCustom = true
                selectedExercises = []
            }
            .font(.footnote)
        }
    }

    /// Star at the trailing edge of a catalog row. `.borderless` so it takes its own taps
    /// instead of the row's select button swallowing them. Filled/outline carries the
    /// state rather than colour — accent is reserved for "done / on target / primary".
    private func favoriteButton(for exercise: Exercise) -> some View {
        let isFavorite = store.isFavorite(exercise.name)
        return Button {
            store.toggleFavorite(exercise.name)
        } label: {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .font(.footnote)
                .foregroundStyle(isFavorite ? Theme.textPrimary : Theme.textSecondary.opacity(0.5))
                .frame(width: 44, height: 36, alignment: .trailing)
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(isFavorite ? "Unfavorite \(exercise.name)" : "Favorite \(exercise.name)")
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
            isBodyweight: userSetBodyweight,
            note: targetNote
        )
    }

    /// Reads the summarised default but writes a real override, so once the user touches
    /// the toggle their choice applies to everything selected instead of the catalog's.
    private var userSetBodyweight: Binding<Bool> {
        Binding(
            get: { effectiveBodyweight },
            set: { newValue in
                isBodyweight = newValue
                didOverrideBodyweight = true
            }
        )
    }

    // MARK: - Actions

    private func applyTemplateCategoryOnce() {
        guard !didApplyTemplateCategory else { return }
        didApplyTemplateCategory = true
        categoryFilter = template?.category
    }

    /// Tapping a row adds it to the selection, tapping it again removes it. Note that
    /// nothing here writes `isBodyweight` — that's what used to make the toggle look
    /// broken (turn it off on Dips, brush the row again, it snapped back on). The toggle
    /// derives its value from the selection instead, via `effectiveBodyweight`.
    private func toggleSelection(_ exercise: Exercise) {
        if let index = selectedExercises.firstIndex(where: { $0.id == exercise.id }) {
            selectedExercises.remove(at: index)
        } else {
            selectedExercises.append(exercise)
        }
    }

    private func addEntry() {
        if isAddingCustom {
            let entry = ExerciseTemplateEntry(
                exerciseName: customExerciseName,
                targetSets: targetSets,
                repRangeLow: repRangeLow,
                repRangeHigh: repRangeHigh,
                isBodyweight: isBodyweight,
                muscleGroups: customExerciseMuscles
            )
            store.addExercises([entry], to: templateID)
            dismiss()
            return
        }

        let entries = selectedExercises.map { exercise in
            ExerciseTemplateEntry(
                exerciseName: exercise.name,
                targetSets: targetSets,
                repRangeLow: repRangeLow,
                repRangeHigh: repRangeHigh,
                // Sets and reps are shared, but bodyweight isn't: selecting Pull Ups and
                // Barbell Row together shouldn't mark the row as bodyweight.
                isBodyweight: didOverrideBodyweight ? isBodyweight : exercise.defaultsToBodyweight,
                muscleGroups: exercise.primaryMuscleGroups
            )
        }
        store.addExercises(entries, to: templateID)
        dismiss()
    }
}

#Preview {
    AddExerciseEntryView(templateID: SeedTemplates.push.id)
        .environmentObject(WorkoutStore())
}
