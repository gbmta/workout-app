import Foundation

/// One exercise's slot within a workout template, seeded from the user's own
/// notes-app history. `loggedWeights`/`loggedReps` hold the last known values
/// per set — nil entries are simply unknown history, not an error state.
struct ExerciseTemplateEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var exerciseName: String
    var targetSets: Int
    var repRangeLow: Int
    var repRangeHigh: Int
    var loggedWeights: [Double?]
    var loggedReps: [Int?]
    var isBodyweight: Bool
    var notes: String?
    /// Muscles this entry trains. nil means "resolve from the exercise catalog
    /// by name" — kept optional so previously saved data still decodes, and so
    /// custom exercises (absent from the catalog) can carry their own muscles.
    var muscleGroups: [MuscleGroup]?

    init(
        id: UUID = UUID(),
        exerciseName: String,
        targetSets: Int,
        repRangeLow: Int,
        repRangeHigh: Int,
        loggedWeights: [Double?] = [],
        loggedReps: [Int?] = [],
        isBodyweight: Bool = false,
        notes: String? = nil,
        muscleGroups: [MuscleGroup]? = nil
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.targetSets = targetSets
        self.repRangeLow = repRangeLow
        self.repRangeHigh = repRangeHigh
        self.loggedWeights = loggedWeights
        self.loggedReps = loggedReps
        self.isBodyweight = isBodyweight
        self.notes = notes
        self.muscleGroups = muscleGroups
    }

    /// Muscles for volume math: the entry's own tags when present, otherwise
    /// the catalog's.
    var resolvedMuscleGroups: [MuscleGroup] {
        muscleGroups ?? SeedExercises.exercise(named: exerciseName)?.primaryMuscleGroups ?? []
    }
}

struct WorkoutTemplate: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    /// Which split day this is, used to pre-filter the exercise picker.
    /// Optional: older saved templates and freeform ones have no category.
    var category: ExerciseCategory?
    var exercises: [ExerciseTemplateEntry]

    init(
        id: UUID = UUID(),
        name: String,
        category: ExerciseCategory? = nil,
        exercises: [ExerciseTemplateEntry]
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.exercises = exercises
    }

    /// Total target sets this template puts on a muscle in one session.
    func targetSets(for muscle: MuscleGroup) -> Int {
        exercises
            .filter { $0.resolvedMuscleGroups.contains(muscle) }
            .reduce(0) { $0 + $1.targetSets }
    }

    /// Every muscle this template trains, in canonical MuscleGroup order.
    var musclesTrained: [MuscleGroup] {
        MuscleGroup.allCases.filter { targetSets(for: $0) > 0 }
    }
}
