import Foundation

struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var categories: [ExerciseCategory]
    var primaryMuscleGroups: [MuscleGroup]
    var defaultsToBodyweight: Bool
    var tips: [InfluencerTip]

    init(
        id: UUID = UUID(),
        name: String,
        categories: [ExerciseCategory],
        primaryMuscleGroups: [MuscleGroup],
        defaultsToBodyweight: Bool = false,
        tips: [InfluencerTip] = []
    ) {
        self.id = id
        self.name = name
        self.categories = categories
        self.primaryMuscleGroups = primaryMuscleGroups
        self.defaultsToBodyweight = defaultsToBodyweight
        self.tips = tips
    }
}
