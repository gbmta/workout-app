import SwiftUI

/// The exercise demo slot on the workout screen. When the current exercise has
/// an animated motion diagram (`ExercisePoses`), it shows that plus a "feel"
/// cue; otherwise it falls back to a compact "Demo coming soon" placeholder.
/// Kept compact so the set logger stays the hero of the screen.
struct ExerciseMediaPlaceholderView: View {
    let exerciseName: String

    var body: some View {
        if let pose = ExercisePoses.byName[exerciseName] {
            VStack(alignment: .leading, spacing: 10) {
                ExerciseMotionDiagramView(pose: pose)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                if !pose.feel.isEmpty {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("Feel")
                            .sectionLabel()
                            .frame(width: 40, alignment: .leading)
                        Text(pose.feel)
                            .font(.footnote)
                            .foregroundStyle(Theme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 4)
                }
            }
        } else {
            HStack(spacing: 12) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.title3)
                    .foregroundStyle(Theme.textSecondary)
                Text("Demo coming soon")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview("With diagram") {
    ExerciseMediaPlaceholderView(exerciseName: "Barbell Bench Press")
        .padding()
        .background(Theme.bg)
}

#Preview("Fallback") {
    ExerciseMediaPlaceholderView(exerciseName: "Pec Deck")
        .padding()
        .background(Theme.bg)
}
