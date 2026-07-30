import Foundation

/// A single logged set, performed on a specific date. This is what the
/// weekly volume tracker aggregates by muscle group, and the shape (keyed by
/// user + date) is deliberately generic so a future nutrition/macro log can
/// sit alongside it without reworking the workout data model.
struct SetLog: Identifiable, Codable, Hashable {
    let id: UUID
    var exerciseName: String
    var performedAt: Date
    var weight: Double?
    var reps: Int
    var isBodyweight: Bool
    /// nil falls back to a catalog lookup by name — see
    /// `ExerciseTemplateEntry.muscleGroups` for why this is optional.
    var muscleGroups: [MuscleGroup]?

    init(
        id: UUID = UUID(),
        exerciseName: String,
        performedAt: Date = Date(),
        weight: Double? = nil,
        reps: Int,
        isBodyweight: Bool = false,
        muscleGroups: [MuscleGroup]? = nil
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.performedAt = performedAt
        self.weight = weight
        self.reps = reps
        self.isBodyweight = isBodyweight
        self.muscleGroups = muscleGroups
    }

    var resolvedMuscleGroups: [MuscleGroup] {
        muscleGroups ?? SeedExercises.exercise(named: exerciseName)?.primaryMuscleGroups ?? []
    }
}
