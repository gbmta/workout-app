import Foundation

enum AppTab: Hashable {
    case templates
    case workout
    case volume
}

/// Holds the user's workout templates, in-progress session, and logged sets,
/// persisting each to its own JSON file in the app's Documents directory.
/// This is a local stand-in for the backend — once the API lands (Phase 3/4
/// of the plan), this store's methods become network calls instead of file
/// writes, without changing the views.
@MainActor
final class WorkoutStore: ObservableObject {
    @Published private(set) var templates: [WorkoutTemplate]
    @Published private(set) var activeSession: WorkoutSession?
    @Published private(set) var setLogs: [SetLog]
    @Published var selectedTab: AppTab = .templates

    private static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private let templatesURL = documentsDirectory.appendingPathComponent("workout_templates.json")
    private let sessionURL = documentsDirectory.appendingPathComponent("active_session.json")
    private let setLogsURL = documentsDirectory.appendingPathComponent("set_logs.json")

    init() {
        templates = Self.load([WorkoutTemplate].self, from: templatesURL) ?? SeedTemplates.all
        activeSession = Self.load(WorkoutSession.self, from: sessionURL)
        setLogs = Self.load([SetLog].self, from: setLogsURL) ?? []
        backfillTemplateCategories()
    }

    /// Templates saved before categories existed decode with `category == nil`.
    /// Guess one from the name so the exercise picker filters usefully instead
    /// of defaulting to the whole library.
    private func backfillTemplateCategories() {
        var didChange = false
        for index in templates.indices where templates[index].category == nil {
            guard let inferred = ExerciseCategory.inferred(fromTemplateName: templates[index].name) else { continue }
            templates[index].category = inferred
            didChange = true
        }
        if didChange {
            saveTemplates()
        }
    }

    // MARK: - Templates

    /// Returns the new template's id so callers can navigate straight into it.
    @discardableResult
    func addTemplate(name: String, category: ExerciseCategory? = nil) -> WorkoutTemplate.ID {
        let template = WorkoutTemplate(name: name, category: category, exercises: [])
        templates.append(template)
        saveTemplates()
        return template.id
    }

    func deleteTemplates(at offsets: IndexSet) {
        templates.remove(atOffsets: offsets)
        saveTemplates()
    }

    func addExercise(_ entry: ExerciseTemplateEntry, to templateID: WorkoutTemplate.ID) {
        guard let index = templates.firstIndex(where: { $0.id == templateID }) else { return }
        templates[index].exercises.append(entry)
        saveTemplates()
    }

    func updateNotes(_ notes: String?, forExercise entryID: ExerciseTemplateEntry.ID, in templateID: WorkoutTemplate.ID) {
        guard let templateIndex = templates.firstIndex(where: { $0.id == templateID }),
              let entryIndex = templates[templateIndex].exercises.firstIndex(where: { $0.id == entryID }) else { return }
        templates[templateIndex].exercises[entryIndex].notes = notes?.isEmpty == true ? nil : notes
        saveTemplates()
    }

    func updateNotes(_ notes: String?, forExerciseNamed exerciseName: String, in templateID: WorkoutTemplate.ID) {
        guard let templateIndex = templates.firstIndex(where: { $0.id == templateID }),
              let entryIndex = templates[templateIndex].exercises.firstIndex(where: { $0.exerciseName == exerciseName }) else { return }
        templates[templateIndex].exercises[entryIndex].notes = notes?.isEmpty == true ? nil : notes
        saveTemplates()
    }

    func deleteExercises(at offsets: IndexSet, from templateID: WorkoutTemplate.ID) {
        guard let index = templates.firstIndex(where: { $0.id == templateID }) else { return }
        templates[index].exercises.remove(atOffsets: offsets)
        saveTemplates()
    }

    // MARK: - Workout sessions

    func startSession(from templateID: WorkoutTemplate.ID) {
        guard activeSession == nil else { return }
        guard let template = templates.first(where: { $0.id == templateID }) else { return }

        let sessionExercises = template.exercises.map { entry in
            SessionExercise(
                exerciseName: entry.exerciseName,
                targetSets: entry.targetSets,
                repRangeLow: entry.repRangeLow,
                repRangeHigh: entry.repRangeHigh,
                previousWeights: entry.loggedWeights,
                previousReps: entry.loggedReps,
                sets: (0..<max(entry.targetSets, 0)).map { _ in SessionSet(isBodyweight: entry.isBodyweight) },
                muscleGroups: entry.resolvedMuscleGroups
            )
        }

        activeSession = WorkoutSession(
            templateID: template.id,
            templateName: template.name,
            exercises: sessionExercises
        )
        selectedTab = .workout
        saveSession()
    }

    func updateSet(exerciseIndex: Int, setIndex: Int, weight: Double?, reps: Int?) {
        guard var session = activeSession,
              session.exercises.indices.contains(exerciseIndex),
              session.exercises[exerciseIndex].sets.indices.contains(setIndex) else { return }
        session.exercises[exerciseIndex].sets[setIndex].weight = weight
        session.exercises[exerciseIndex].sets[setIndex].reps = reps
        activeSession = session
        saveSession()
    }

    /// One-tap logging: fill an empty set from the best available reference —
    /// last session's same set, else the nearest earlier set logged today,
    /// else the bottom of the rep range — then persist. Values already typed
    /// by the user are never overwritten.
    func logSet(exerciseIndex: Int, setIndex: Int) {
        guard var session = activeSession,
              session.exercises.indices.contains(exerciseIndex),
              session.exercises[exerciseIndex].sets.indices.contains(setIndex) else { return }
        var exercise = session.exercises[exerciseIndex]
        var set = exercise.sets[setIndex]

        if set.reps == nil {
            set.reps = (setIndex < exercise.previousReps.count ? exercise.previousReps[setIndex] : nil)
                ?? exercise.sets[..<setIndex].reversed().compactMap(\.reps).first
                ?? (exercise.repRangeLow > 0 ? exercise.repRangeLow : nil)
        }
        if set.weight == nil && !set.isBodyweight {
            set.weight = (setIndex < exercise.previousWeights.count ? exercise.previousWeights[setIndex] : nil)
                ?? exercise.sets[..<setIndex].reversed().compactMap(\.weight).first
        }

        exercise.sets[setIndex] = set
        session.exercises[exerciseIndex] = exercise
        activeSession = session
        saveSession()
    }

    func addSet(toExerciseIndex exerciseIndex: Int) {
        guard var session = activeSession, session.exercises.indices.contains(exerciseIndex) else { return }
        session.exercises[exerciseIndex].sets.append(SessionSet())
        activeSession = session
        saveSession()
    }

    func goToExercise(index: Int) {
        guard var session = activeSession else { return }
        session.currentExerciseIndex = max(0, min(index, session.exercises.count - 1))
        activeSession = session
        saveSession()
    }

    func finishSession() {
        guard let session = activeSession else { return }

        let newLogs = session.exercises.flatMap { exercise in
            exercise.sets.compactMap { set -> SetLog? in
                guard let reps = set.reps else { return nil }
                return SetLog(
                    exerciseName: exercise.exerciseName,
                    weight: set.weight,
                    reps: reps,
                    isBodyweight: set.isBodyweight,
                    muscleGroups: exercise.resolvedMuscleGroups
                )
            }
        }
        setLogs.append(contentsOf: newLogs)
        saveSetLogs()

        if let templateIndex = templates.firstIndex(where: { $0.id == session.templateID }) {
            for exercise in session.exercises {
                // Only overwrite history for exercises the user actually logged something for —
                // every exercise starts with empty prefilled rows, so most sessions leave most
                // exercises untouched and their prior "last time" values should survive.
                guard exercise.sets.contains(where: { $0.reps != nil }) else { continue }
                guard let entryIndex = templates[templateIndex].exercises.firstIndex(where: { $0.exerciseName == exercise.exerciseName }) else { continue }
                templates[templateIndex].exercises[entryIndex].loggedWeights = exercise.sets.map(\.weight)
                templates[templateIndex].exercises[entryIndex].loggedReps = exercise.sets.map(\.reps)
            }
            saveTemplates()
        }

        activeSession = nil
        try? FileManager.default.removeItem(at: sessionURL)
    }

    func cancelSession() {
        activeSession = nil
        try? FileManager.default.removeItem(at: sessionURL)
    }

    // MARK: - Volume

    func weeklySets(for muscleGroup: MuscleGroup) -> Int {
        guard let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else { return 0 }
        return setLogs.filter { $0.performedAt >= cutoff }
            .filter { $0.resolvedMuscleGroups.contains(muscleGroup) }
            .count
    }

    // MARK: - Persistence

    private func saveTemplates() {
        save(templates, to: templatesURL)
    }

    private func saveSession() {
        save(activeSession, to: sessionURL)
    }

    private func saveSetLogs() {
        save(setLogs, to: setLogsURL)
    }

    private func save<T: Encodable>(_ value: T, to url: URL) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        try? data.write(to: url)
    }

    private static func load<T: Decodable>(_ type: T.Type, from url: URL) -> T? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
