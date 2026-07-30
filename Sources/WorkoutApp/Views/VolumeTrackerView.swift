import SwiftUI

/// Last 7 days of logged sets per muscle group against the research-based
/// weekly range, with zone coloring: dim below the minimum, accent in range,
/// amber above the max.
struct VolumeTrackerView: View {
    @EnvironmentObject private var store: WorkoutStore

    let guidelines = HypertrophyVolumeGuideline.all

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(guidelines, id: \.muscleGroup) { guideline in
                        MuscleVolumeCard(
                            guideline: guideline,
                            logged: store.weeklySets(for: guideline.muscleGroup)
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                } header: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("This Week")
                            .sectionLabel()
                        Text("rolling last 7 days")
                            .font(.caption2)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
            .navigationTitle("Weekly Volume")
        }
    }
}

private struct MuscleVolumeCard: View {
    let guideline: HypertrophyVolumeGuideline
    let logged: Int

    private var zoneColor: Color {
        if logged < guideline.minWeeklySets { return Theme.zoneUnder }
        if logged > guideline.maxWeeklySets { return Theme.warn }
        return Theme.accent
    }

    private var fillFraction: Double {
        min(Double(logged), Double(guideline.maxWeeklySets)) / Double(guideline.maxWeeklySets)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: symbol(for: guideline.muscleGroup))
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .frame(width: 22)
                    Text(guideline.muscleGroup.displayName)
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                }
                Spacer()
                Text("\(logged) / \(guideline.minWeeklySets)–\(guideline.maxWeeklySets)")
                    .font(Theme.numberFont(17))
                    .monospacedDigit()
                    .foregroundStyle(Theme.textPrimary)
                    .contentTransition(.numericText())
                    .animation(.spring(duration: 0.3), value: logged)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.surfaceRaised)
                    Capsule()
                        .fill(zoneColor)
                        .frame(width: max(fillFraction > 0 ? 8 : 0, geometry.size.width * fillFraction))
                }
            }
            .frame(height: 8)

            if logged < guideline.minWeeklySets {
                Text("\(guideline.minWeeklySets - logged) to go")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .themeCard()
    }

    private func symbol(for muscle: MuscleGroup) -> String {
        switch muscle {
        case .chest: "figure.arms.open"
        case .back: "figure.climbing"
        case .shoulders: "figure.boxing"
        case .biceps, .triceps: "dumbbell"
        case .quads, .hamstrings, .glutes: "figure.walk"
        case .calves: "figure.stairs"
        case .abs: "figure.core.training"
        }
    }
}

#Preview {
    VolumeTrackerView()
        .environmentObject(WorkoutStore())
}
