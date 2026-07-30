import Foundation

/// Transcribed from the user's notes-app photos. Where a historical value was
/// cut off or blank in the source photo it's stored as nil — unknown history,
/// shown as a blank/dash in the UI, never an error.
enum SeedTemplates {
    static let push = WorkoutTemplate(
        name: "Push",
        category: .push,
        exercises: [
            ExerciseTemplateEntry(
                exerciseName: "Incline Smith Machine Press",
                targetSets: 4,
                repRangeLow: 8,
                repRangeHigh: 10,
                loggedWeights: [70, 70, 70, nil],
                loggedReps: [10, 8, 8, nil]
            ),
            ExerciseTemplateEntry(
                exerciseName: "Pec Deck",
                targetSets: 3,
                repRangeLow: 10,
                repRangeHigh: 15,
                loggedWeights: [55, 45, 45],
                loggedReps: [12, 12, 12]
            ),
            ExerciseTemplateEntry(
                exerciseName: "Arnold Press",
                targetSets: 3,
                repRangeLow: 8,
                repRangeHigh: 12,
                loggedWeights: [15, 15, 15],
                loggedReps: [10, 10, 8]
            ),
            ExerciseTemplateEntry(
                exerciseName: "Lateral Raise",
                targetSets: 3,
                repRangeLow: 12,
                repRangeHigh: 20,
                loggedWeights: [10, 10, 10],
                loggedReps: [10, 10, 10]
            ),
            ExerciseTemplateEntry(
                exerciseName: "Overhead Tricep Extension",
                targetSets: 3,
                repRangeLow: 10,
                repRangeHigh: 15,
                loggedWeights: [35, 42.5, 35],
                loggedReps: [18, 12, 13]
            ),
            ExerciseTemplateEntry(
                exerciseName: "Cable Push Down",
                targetSets: 3,
                repRangeLow: 10,
                repRangeHigh: 15
            ),
        ]
    )

    static let pull = WorkoutTemplate(
        name: "Pull",
        category: .pull,
        exercises: [
            // Set 1 read as a regular (unassisted) pull-up, sets 2-4 on the
            // assisted machine at -55 lb.
            ExerciseTemplateEntry(
                exerciseName: "Pull Ups",
                targetSets: 4,
                repRangeLow: 6,
                repRangeHigh: 10,
                loggedWeights: [nil, -55, -55, -55],
                loggedReps: [7, 10, 8, 5]
            ),
            ExerciseTemplateEntry(
                exerciseName: "Unilateral Seated Row",
                targetSets: 3,
                repRangeLow: 8,
                repRangeHigh: 12,
                loggedWeights: [10, 10, 10],
                loggedReps: [12, 16, 15]
            ),
            ExerciseTemplateEntry(
                exerciseName: "Reverse Pec Deck",
                targetSets: 3,
                repRangeLow: 12,
                repRangeHigh: 20,
                loggedWeights: [50, 50, 50],
                loggedReps: [10, 10, 14]
            ),
            ExerciseTemplateEntry(
                exerciseName: "Face Pulls",
                targetSets: 3,
                repRangeLow: 15,
                repRangeHigh: 20,
                loggedWeights: [27.5, 27.5, 27.5],
                loggedReps: [15, 15, 10]
            ),
            ExerciseTemplateEntry(
                exerciseName: "Cable Curls",
                targetSets: 3,
                repRangeLow: 12,
                repRangeHigh: 15,
                loggedWeights: [12.5, 12.5, 12.5],
                loggedReps: [15, 12, nil]
            ),
            ExerciseTemplateEntry(
                exerciseName: "Hammer Curls",
                targetSets: 2,
                repRangeLow: 12,
                repRangeHigh: 15
            ),
        ]
    )

    static let legs = WorkoutTemplate(
        name: "Legs",
        category: .legs,
        exercises: [
            ExerciseTemplateEntry(
                exerciseName: "Leg Press",
                targetSets: 3,
                repRangeLow: 8,
                repRangeHigh: 8,
                loggedWeights: [140, 140, 140],
                loggedReps: [8, 8, 10]
            ),
            ExerciseTemplateEntry(
                exerciseName: "Romanian Deadlift",
                targetSets: 3,
                repRangeLow: 8,
                repRangeHigh: 8,
                loggedWeights: [135, 135, 135],
                loggedReps: [8, 8, 8]
            ),
            ExerciseTemplateEntry(
                exerciseName: "Leg Curl",
                targetSets: 3,
                repRangeLow: 8,
                repRangeHigh: 12,
                loggedWeights: [70, 70, 70],
                loggedReps: [11, 9, nil]
            ),
            ExerciseTemplateEntry(
                exerciseName: "Leg Extension",
                targetSets: 3,
                repRangeLow: 12,
                repRangeHigh: 15,
                loggedWeights: [70, 70, 70],
                loggedReps: [12, 9, nil]
            ),
            ExerciseTemplateEntry(
                exerciseName: "Standing Calf Raise",
                targetSets: 3,
                repRangeLow: 10,
                repRangeHigh: 15,
                loggedWeights: [25, 25, 25],
                loggedReps: [15, 15, nil]
            ),
            ExerciseTemplateEntry(
                exerciseName: "Cable Crunchers",
                targetSets: 3,
                repRangeLow: 10,
                repRangeHigh: 15,
                loggedWeights: [70, 70, 70],
                loggedReps: [15, 15, nil]
            ),
            ExerciseTemplateEntry(
                exerciseName: "Leg Raise",
                targetSets: 3,
                repRangeLow: 10,
                repRangeHigh: 15,
                loggedWeights: [nil, nil, nil],
                loggedReps: [10, nil, nil],
                isBodyweight: true
            ),
        ]
    )

    static let all: [WorkoutTemplate] = [push, pull, legs]
}
