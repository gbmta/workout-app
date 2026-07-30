import Foundation

/// One set being logged live during a workout. A set only "counts" once
/// `reps` is filled in — there's no separate completed flag to manage.
struct SessionSet: Identifiable, Codable, Hashable {
    let id: UUID
    var weight: Double?
    var reps: Int?
    var isBodyweight: Bool

    init(id: UUID = UUID(), weight: Double? = nil, reps: Int? = nil, isBodyweight: Bool = false) {
        self.id = id
        self.weight = weight
        self.reps = reps
        self.isBodyweight = isBodyweight
    }
}

/// An exercise within an in-progress session, snapshotted from the source
/// template at start time so edits to the template mid-workout don't shift
/// the session underneath the user. `previousWeights`/`previousReps` are the
/// template's last-known values, shown as reference only.
struct SessionExercise: Identifiable, Codable, Hashable {
    let id: UUID
    var exerciseName: String
    var targetSets: Int
    var repRangeLow: Int
    var repRangeHigh: Int
    var previousWeights: [Double?]
    var previousReps: [Int?]
    var sets: [SessionSet]
    var muscleGroups: [MuscleGroup]?

    init(
        id: UUID = UUID(),
        exerciseName: String,
        targetSets: Int,
        repRangeLow: Int,
        repRangeHigh: Int,
        previousWeights: [Double?] = [],
        previousReps: [Int?] = [],
        sets: [SessionSet] = [],
        muscleGroups: [MuscleGroup]? = nil
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.targetSets = targetSets
        self.repRangeLow = repRangeLow
        self.repRangeHigh = repRangeHigh
        self.previousWeights = previousWeights
        self.previousReps = previousReps
        self.sets = sets
        self.muscleGroups = muscleGroups
    }

    var resolvedMuscleGroups: [MuscleGroup] {
        muscleGroups ?? SeedExercises.exercise(named: exerciseName)?.primaryMuscleGroups ?? []
    }
}

struct WorkoutSession: Identifiable, Codable {
    let id: UUID
    var templateID: WorkoutTemplate.ID
    var templateName: String
    var startedAt: Date
    var currentExerciseIndex: Int
    var exercises: [SessionExercise]

    init(
        id: UUID = UUID(),
        templateID: WorkoutTemplate.ID,
        templateName: String,
        startedAt: Date = Date(),
        currentExerciseIndex: Int = 0,
        exercises: [SessionExercise]
    ) {
        self.id = id
        self.templateID = templateID
        self.templateName = templateName
        self.startedAt = startedAt
        self.currentExerciseIndex = currentExerciseIndex
        self.exercises = exercises
    }
}
