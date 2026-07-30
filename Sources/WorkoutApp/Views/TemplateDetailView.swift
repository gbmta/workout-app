import SwiftUI

struct TemplateDetailView: View {
    let templateID: WorkoutTemplate.ID

    @EnvironmentObject private var store: WorkoutStore
    @State private var isPresentingAddExercise = false
    @State private var editingNoteFor: ExerciseTemplateEntry?
    @State private var editingTargetFor: ExerciseTemplateEntry?

    private var template: WorkoutTemplate? {
        store.templates.first { $0.id == templateID }
    }

    var body: some View {
        Group {
            if let template {
                Group {
                    if template.exercises.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "dumbbell")
                                .font(.system(size: 44))
                                .foregroundStyle(Theme.accent)
                            Text("No exercises yet")
                                .font(.title3.bold())
                                .foregroundStyle(Theme.textPrimary)
                            Text("Add the exercises you'll do on\n\(template.name) day.")
                                .font(.subheadline)
                                .foregroundStyle(Theme.textSecondary)
                                .multilineTextAlignment(.center)
                            Button {
                                isPresentingAddExercise = true
                            } label: {
                                Label("Add Exercise", systemImage: "plus")
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
                    } else {
                        List {
                            TemplateVolumeSummaryCard(template: template)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))

                            ForEach(template.exercises) { entry in
                                Button {
                                    editingTargetFor = entry
                                } label: {
                                    ExerciseEntryCard(entry: entry) {
                                        editingNoteFor = entry
                                    }
                                }
                                .buttonStyle(.plain)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            }
                            .onDelete { offsets in
                                store.deleteExercises(at: offsets, from: templateID)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(Theme.bg)
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    if store.activeSession == nil && !template.exercises.isEmpty {
                        Button {
                            store.startSession(from: templateID)
                        } label: {
                            Label("Start Workout", systemImage: "play.fill")
                                .font(.headline)
                                .foregroundStyle(Theme.onAccent)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                        }
                        .background(Theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding()
                    }
                }
                .navigationTitle(template.name)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isPresentingAddExercise = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $isPresentingAddExercise) {
                    AddExerciseEntryView(templateID: templateID)
                }
                .sheet(item: $editingNoteFor) { entry in
                    EditExerciseNoteView(templateID: templateID, entry: entry)
                }
                .sheet(item: $editingTargetFor) { entry in
                    EditExerciseTargetView(templateID: templateID, entry: entry)
                }
            } else {
                ContentUnavailableView("Template deleted", systemImage: "trash")
            }
        }
    }
}

private struct ExerciseEntryCard: View {
    let entry: ExerciseTemplateEntry
    let onEditNote: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(entry.exerciseName)
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Button(action: onEditNote) {
                    Image(systemName: "note.text")
                        .foregroundStyle(entry.notes?.isEmpty == false ? Theme.accent : Theme.textSecondary)
                        .frame(width: 44, height: 32, alignment: .trailing)
                }
                .buttonStyle(.borderless)
            }

            HStack(spacing: 6) {
                Text("\(entry.targetSets) × \(entry.repRangeLow)–\(entry.repRangeHigh)")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                ForEach(entry.resolvedMuscleGroups) { muscle in
                    Text(muscle.displayName)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Theme.surfaceRaised)
                        .clipShape(Capsule())
                }
            }

            Text(historyLine(for: entry))
                .font(Theme.numberFont(15))
                .monospacedDigit()
                .foregroundStyle(Theme.textSecondary)

            if let notes = entry.notes, !notes.isEmpty {
                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "note.text")
                    Text(notes)
                }
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
            }

        }
        .themeCard()
    }

    private func historyLine(for entry: ExerciseTemplateEntry) -> String {
        let count = max(entry.loggedWeights.count, entry.loggedReps.count)

        let pairs = (0..<count).compactMap { index -> String? in
            let weight = index < entry.loggedWeights.count ? entry.loggedWeights[index] : nil
            let reps = index < entry.loggedReps.count ? entry.loggedReps[index] : nil
            // A set where both sides are unknown is noise, not history.
            guard weight != nil || reps != nil else { return nil }
            let weightLabel = entry.isBodyweight ? "BW" : weight.map { formatWeight($0, isBodyweight: false) } ?? "–"
            let repsLabel = reps.map(String.init) ?? "–"
            return "\(weightLabel)×\(repsLabel)"
        }
        guard !pairs.isEmpty else { return "No history yet" }
        return "Last: " + pairs.joined(separator: " · ")
    }
}

#Preview {
    NavigationStack {
        TemplateDetailView(templateID: SeedTemplates.push.id)
            .environmentObject(WorkoutStore())
    }
}
