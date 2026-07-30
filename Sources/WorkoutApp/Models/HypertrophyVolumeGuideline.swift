import Foundation

/// Weekly direct working-set ranges per muscle group, for the volume tracker's
/// goal line. These are approximate, commonly-cited ranges synthesized from
/// hypertrophy training volume research (e.g. Schoenfeld et al.'s dose-response
/// meta-analyses and the MEV/MAV/MRV framework popularized by Renaissance
/// Periodization) — not a substitute for individual programming, and indirect
/// volume (e.g. triceps worked during pressing) is not counted here.
struct HypertrophyVolumeGuideline {
    let muscleGroup: MuscleGroup
    let minWeeklySets: Int
    let maxWeeklySets: Int

    static let all: [HypertrophyVolumeGuideline] = [
        .init(muscleGroup: .chest, minWeeklySets: 10, maxWeeklySets: 20),
        .init(muscleGroup: .back, minWeeklySets: 10, maxWeeklySets: 20),
        .init(muscleGroup: .shoulders, minWeeklySets: 8, maxWeeklySets: 16),
        .init(muscleGroup: .biceps, minWeeklySets: 8, maxWeeklySets: 14),
        .init(muscleGroup: .triceps, minWeeklySets: 8, maxWeeklySets: 14),
        .init(muscleGroup: .quads, minWeeklySets: 8, maxWeeklySets: 16),
        .init(muscleGroup: .hamstrings, minWeeklySets: 6, maxWeeklySets: 12),
        .init(muscleGroup: .glutes, minWeeklySets: 6, maxWeeklySets: 12),
        .init(muscleGroup: .calves, minWeeklySets: 8, maxWeeklySets: 16),
        .init(muscleGroup: .abs, minWeeklySets: 8, maxWeeklySets: 16),
    ]

    static func guideline(for muscleGroup: MuscleGroup) -> HypertrophyVolumeGuideline? {
        all.first { $0.muscleGroup == muscleGroup }
    }
}
