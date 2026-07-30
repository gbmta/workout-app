import SwiftUI

/// Shows what a template does for you: which muscles it trains, how many sets
/// each gets, and — using your real logged sets from the last 7 days — where
/// running it once more would leave you against the weekly hypertrophy range.
struct TemplateVolumeSummaryCard: View {
    let template: WorkoutTemplate

    @EnvironmentObject private var store: WorkoutStore

    private var rows: [Row] {
        template.musclesTrained.map { muscle in
            let guideline = HypertrophyVolumeGuideline.guideline(for: muscle)
            return Row(
                muscle: muscle,
                templateSets: template.targetSets(for: muscle),
                loggedThisWeek: store.weeklySets(for: muscle),
                minWeekly: guideline?.minWeeklySets ?? 0,
                maxWeekly: guideline?.maxWeeklySets ?? 0
            )
        }
    }

    private var totalSets: Int {
        template.exercises.reduce(0) { $0 + $1.targetSets }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("This Workout")
                    .sectionLabel()
                Spacer()
                Text("\(totalSets) set\(totalSets == 1 ? "" : "s")")
                    .font(Theme.numberFont(13))
                    .monospacedDigit()
                    .foregroundStyle(Theme.textSecondary)
            }

            let muscleCount = rows.count
            Text("Hits \(muscleCount) muscle group\(muscleCount == 1 ? "" : "s")")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)

            VStack(spacing: 10) {
                ForEach(rows) { row in
                    MuscleRow(row: row)
                }
            }

            Text("Projection adds this workout to the sets you've logged in the last 7 days.")
                .font(.caption2)
                .foregroundStyle(Theme.textSecondary)
        }
        .themeCard()
    }

    struct Row: Identifiable {
        let muscle: MuscleGroup
        let templateSets: Int
        let loggedThisWeek: Int
        let minWeekly: Int
        let maxWeekly: Int

        var id: MuscleGroup { muscle }
        var projected: Int { loggedThisWeek + templateSets }

        var zone: Zone {
            if projected < minWeekly { return .under }
            if projected > maxWeekly { return .over }
            return .inRange
        }

        enum Zone {
            case under, inRange, over

            var color: Color {
                switch self {
                case .under: Theme.zoneUnder
                case .inRange: Theme.accent
                case .over: Theme.warn
                }
            }
        }
    }
}

private struct MuscleRow: View {
    let row: TemplateVolumeSummaryCard.Row

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(row.muscle.displayName)
                    .font(.subheadline)
                    .foregroundStyle(Theme.textPrimary)
                Text("+\(row.templateSets)")
                    .font(Theme.numberFont(13))
                    .monospacedDigit()
                    .foregroundStyle(Theme.accent)
                Spacer()
                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(row.zone.color)
            }

            GeometryReader { geometry in
                let maxWeekly = max(row.maxWeekly, 1)
                let loggedFraction = min(Double(row.loggedThisWeek) / Double(maxWeekly), 1)
                let projectedFraction = min(Double(row.projected) / Double(maxWeekly), 1)
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.surfaceRaised)
                    // What this template would add, shown behind the already-logged bar.
                    Capsule()
                        .fill(row.zone.color.opacity(0.45))
                        .frame(width: geometry.size.width * projectedFraction)
                    Capsule()
                        .fill(row.zone.color)
                        .frame(width: geometry.size.width * loggedFraction)
                }
            }
            .frame(height: 6)
        }
    }

    private var statusText: String {
        switch row.zone {
        case .under:
            "\(row.projected) of \(row.minWeekly)–\(row.maxWeekly) · \(row.minWeekly - row.projected) short"
        case .inRange:
            "\(row.projected) of \(row.minWeekly)–\(row.maxWeekly) · on target"
        case .over:
            "\(row.projected) of \(row.minWeekly)–\(row.maxWeekly) · over"
        }
    }
}

#Preview {
    TemplateVolumeSummaryCard(template: SeedTemplates.push)
        .padding()
        .background(Theme.bg)
        .environmentObject(WorkoutStore())
}
