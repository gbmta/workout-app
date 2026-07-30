import SwiftUI

/// Snapshot of a finished session, computed from the live session *before*
/// `finishSession()` clears it.
struct WorkoutSummary: Identifiable {
    let id = UUID()
    let templateName: String
    let durationMinutes: Int
    let totalSets: Int
    let setsPerMuscle: [(muscle: MuscleGroup, sets: Int)]

    init(session: WorkoutSession) {
        templateName = session.templateName
        durationMinutes = max(1, Int(Date().timeIntervalSince(session.startedAt) / 60))

        var loggedSetsByExercise: [(muscles: [MuscleGroup], count: Int)] = []
        for exercise in session.exercises {
            let logged = exercise.sets.filter { $0.reps != nil }.count
            if logged > 0 {
                loggedSetsByExercise.append((exercise.resolvedMuscleGroups, logged))
            }
        }
        totalSets = loggedSetsByExercise.reduce(0) { $0 + $1.count }

        setsPerMuscle = MuscleGroup.allCases.compactMap { muscle in
            let count = loggedSetsByExercise
                .filter { $0.muscles.contains(muscle) }
                .reduce(0) { $0 + $1.count }
            return count > 0 ? (muscle, count) : nil
        }
    }
}

struct WorkoutSummaryView: View {
    let summary: WorkoutSummary
    let onDone: () -> Void
    let onKeepTraining: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.accent)
                .symbolEffect(.bounce, value: appeared)

            VStack(spacing: 4) {
                Text(summary.templateName)
                    .font(.title2.bold())
                    .foregroundStyle(Theme.textPrimary)
                Text("\(summary.durationMinutes) min · \(summary.totalSets) set\(summary.totalSets == 1 ? "" : "s") logged")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }

            if !summary.setsPerMuscle.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sets by muscle")
                        .sectionLabel()
                    ForEach(summary.setsPerMuscle, id: \.muscle) { item in
                        HStack {
                            Text(item.muscle.displayName)
                                .foregroundStyle(Theme.textPrimary)
                            Spacer()
                            Text("\(item.sets)")
                                .font(Theme.numberFont(17))
                                .monospacedDigit()
                                .foregroundStyle(Theme.textPrimary)
                        }
                    }
                }
                .themeCard()
                .padding(.horizontal)
            }

            Spacer()

            VStack(spacing: 12) {
                Button(action: onDone) {
                    Text("Done")
                        .font(.headline)
                        .foregroundStyle(Theme.onAccent)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .background(Theme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                Button("Keep training", action: onKeepTraining)
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .background(Theme.bg)
        .onAppear { appeared = true }
    }
}

#Preview {
    let store = WorkoutStore()
    store.startSession(from: SeedTemplates.push.id)
    return WorkoutSummaryView(
        summary: WorkoutSummary(session: store.activeSession!),
        onDone: {},
        onKeepTraining: {}
    )
}
