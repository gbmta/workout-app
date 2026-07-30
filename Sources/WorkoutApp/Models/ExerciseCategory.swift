import Foundation

/// The split day an exercise belongs to. Exercises can belong to more than one
/// (core work commonly gets appended to a leg day, for example), which is why
/// `Exercise.categories` is a list.
enum ExerciseCategory: String, Codable, CaseIterable, Identifiable {
    case push
    case pull
    case legs
    case core

    var id: String { rawValue }

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    /// Best-effort category from a template name ("Push day" -> .push). Used to
    /// pre-fill the picker while naming a template, and to backfill templates
    /// saved before categories existed.
    static func inferred(fromTemplateName name: String) -> ExerciseCategory? {
        let lowercased = name.lowercased()
        return allCases.first { lowercased.contains($0.rawValue) }
    }
}
