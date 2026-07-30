import Foundation

/// The exercise library. Each entry carries the split day(s) it belongs to and
/// the muscles it primarily trains, which drives the exercise picker's filtering
/// and every per-muscle set count in the app.
///
/// To add an exercise, add one line below — nothing else needs to change.
/// Volume math credits **primary** muscles only; indirect work (triceps during
/// pressing, biceps during rows) is deliberately not counted.
///
/// Names are the join key used by saved templates and set logs, so renaming an
/// existing entry orphans that history. Add a new entry instead.
enum SeedExercises {
    static let catalog: [Exercise] = [
        // MARK: Push — chest
        Exercise(name: "Barbell Bench Press", categories: [.push], primaryMuscleGroups: [.chest]),
        Exercise(name: "Dumbbell Bench Press", categories: [.push], primaryMuscleGroups: [.chest]),
        Exercise(name: "Incline Smith Machine Press", categories: [.push], primaryMuscleGroups: [.chest]),
        Exercise(name: "Incline Dumbbell Press", categories: [.push], primaryMuscleGroups: [.chest]),
        Exercise(name: "Machine Chest Press", categories: [.push], primaryMuscleGroups: [.chest]),
        Exercise(name: "Pec Deck", categories: [.push], primaryMuscleGroups: [.chest]),
        Exercise(name: "Cable Fly", categories: [.push], primaryMuscleGroups: [.chest]),
        Exercise(name: "Dips", categories: [.push], primaryMuscleGroups: [.chest, .triceps], defaultsToBodyweight: true),

        // MARK: Push — shoulders
        Exercise(name: "Overhead Press", categories: [.push], primaryMuscleGroups: [.shoulders]),
        Exercise(name: "Dumbbell Shoulder Press", categories: [.push], primaryMuscleGroups: [.shoulders]),
        Exercise(name: "Arnold Press", categories: [.push], primaryMuscleGroups: [.shoulders]),
        Exercise(name: "Lateral Raise", categories: [.push], primaryMuscleGroups: [.shoulders]),
        Exercise(name: "Cable Lateral Raise", categories: [.push], primaryMuscleGroups: [.shoulders]),

        // MARK: Push — triceps
        Exercise(name: "Close-Grip Bench Press", categories: [.push], primaryMuscleGroups: [.triceps, .chest]),
        Exercise(name: "Overhead Tricep Extension", categories: [.push], primaryMuscleGroups: [.triceps]),
        Exercise(name: "Skull Crusher", categories: [.push], primaryMuscleGroups: [.triceps]),
        Exercise(name: "Cable Push Down", categories: [.push], primaryMuscleGroups: [.triceps]),

        // MARK: Pull — back
        Exercise(name: "Pull Ups", categories: [.pull], primaryMuscleGroups: [.back], defaultsToBodyweight: true),
        Exercise(name: "Chin Ups", categories: [.pull], primaryMuscleGroups: [.back, .biceps], defaultsToBodyweight: true),
        Exercise(name: "Lat Pulldown", categories: [.pull], primaryMuscleGroups: [.back]),
        Exercise(name: "Barbell Row", categories: [.pull], primaryMuscleGroups: [.back]),
        Exercise(name: "Dumbbell Row", categories: [.pull], primaryMuscleGroups: [.back]),
        Exercise(name: "T-Bar Row", categories: [.pull], primaryMuscleGroups: [.back]),
        Exercise(name: "Seated Cable Row", categories: [.pull], primaryMuscleGroups: [.back]),
        Exercise(name: "Unilateral Seated Row", categories: [.pull], primaryMuscleGroups: [.back]),
        Exercise(name: "Shrugs", categories: [.pull], primaryMuscleGroups: [.back]),

        // MARK: Pull — rear delts
        Exercise(name: "Reverse Pec Deck", categories: [.pull], primaryMuscleGroups: [.shoulders]),
        Exercise(name: "Face Pulls", categories: [.pull], primaryMuscleGroups: [.shoulders]),

        // MARK: Pull — biceps
        Exercise(name: "Barbell Curl", categories: [.pull], primaryMuscleGroups: [.biceps]),
        Exercise(name: "Dumbbell Curl", categories: [.pull], primaryMuscleGroups: [.biceps]),
        Exercise(name: "Incline Dumbbell Curl", categories: [.pull], primaryMuscleGroups: [.biceps]),
        Exercise(name: "Cable Curls", categories: [.pull], primaryMuscleGroups: [.biceps]),
        Exercise(name: "Hammer Curls", categories: [.pull], primaryMuscleGroups: [.biceps]),

        // MARK: Legs — quads
        Exercise(name: "Barbell Squat", categories: [.legs], primaryMuscleGroups: [.quads, .glutes]),
        Exercise(name: "Hack Squat", categories: [.legs], primaryMuscleGroups: [.quads]),
        Exercise(name: "Leg Press", categories: [.legs], primaryMuscleGroups: [.quads]),
        Exercise(name: "Bulgarian Split Squat", categories: [.legs], primaryMuscleGroups: [.quads, .glutes]),
        Exercise(name: "Walking Lunge", categories: [.legs], primaryMuscleGroups: [.quads, .glutes]),
        Exercise(name: "Leg Extension", categories: [.legs], primaryMuscleGroups: [.quads]),

        // MARK: Legs — hamstrings & glutes
        Exercise(name: "Conventional Deadlift", categories: [.legs], primaryMuscleGroups: [.hamstrings, .glutes, .back]),
        Exercise(name: "Romanian Deadlift", categories: [.legs], primaryMuscleGroups: [.hamstrings, .glutes]),
        Exercise(name: "Leg Curl", categories: [.legs], primaryMuscleGroups: [.hamstrings]),
        Exercise(name: "Seated Leg Curl", categories: [.legs], primaryMuscleGroups: [.hamstrings]),
        Exercise(name: "Hip Thrust", categories: [.legs], primaryMuscleGroups: [.glutes]),

        // MARK: Legs — calves
        Exercise(name: "Standing Calf Raise", categories: [.legs], primaryMuscleGroups: [.calves]),
        Exercise(name: "Seated Calf Raise", categories: [.legs], primaryMuscleGroups: [.calves]),

        // MARK: Core — tagged legs too, since core work usually rides along on leg day
        Exercise(name: "Cable Crunchers", categories: [.core, .legs], primaryMuscleGroups: [.abs]),
        Exercise(name: "Leg Raise", categories: [.core, .legs], primaryMuscleGroups: [.abs], defaultsToBodyweight: true),
        Exercise(name: "Hanging Leg Raise", categories: [.core], primaryMuscleGroups: [.abs], defaultsToBodyweight: true),
        Exercise(name: "Ab Wheel Rollout", categories: [.core], primaryMuscleGroups: [.abs], defaultsToBodyweight: true),
    ]

    static func exercise(named name: String) -> Exercise? {
        catalog.first { $0.name == name }
    }

    static func catalog(for category: ExerciseCategory?) -> [Exercise] {
        guard let category else { return catalog }
        return catalog.filter { $0.categories.contains(category) }
    }
}
