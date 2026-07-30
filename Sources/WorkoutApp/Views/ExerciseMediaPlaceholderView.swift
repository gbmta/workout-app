import SwiftUI

/// Stand-in for a real exercise demo (photo/video/animation). Kept compact so
/// the set logger stays the hero of the workout screen; swapping in real
/// media later only touches this file.
struct ExerciseMediaPlaceholderView: View {
    var body: some View {
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

#Preview {
    ExerciseMediaPlaceholderView()
        .padding()
        .background(Theme.bg)
}
