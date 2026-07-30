import SwiftUI

struct StartWorkoutPickerView: View {
    @EnvironmentObject private var store: WorkoutStore

    var body: some View {
        NavigationStack {
            if store.templates.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 48))
                        .foregroundStyle(Theme.accent)
                    Text("No templates yet")
                        .font(.title3.bold())
                        .foregroundStyle(Theme.textPrimary)
                    Text("Build a template first, then start\nyour workout from here.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                    Button {
                        store.selectedTab = .templates
                    } label: {
                        Text("Go to Templates")
                            .font(.headline)
                            .foregroundStyle(Theme.onAccent)
                            .padding(.horizontal, 24)
                            .frame(height: 44)
                    }
                    .background(Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.bg)
                .navigationTitle("Workout")
            } else {
                List(store.templates) { template in
                    Button {
                        store.startSession(from: template.id)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(template.name)
                                    .font(.title3.bold())
                                    .foregroundStyle(Theme.textPrimary)
                                Text(exerciseCountLabel(template.exercises.count))
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Theme.accent)
                        }
                    }
                    .disabled(template.exercises.isEmpty)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .themeCard()
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Theme.bg)
                .navigationTitle("Start a Workout")
            }
        }
    }
}

#Preview {
    StartWorkoutPickerView()
        .environmentObject(WorkoutStore())
}
