import SwiftUI
import UIKit

struct ActiveWorkoutView: View {
    @EnvironmentObject private var store: WorkoutStore
    @State private var isShowingCancelConfirmation = false
    @State private var isPresentingExerciseList = false
    @State private var pendingSummary: WorkoutSummary?

    var body: some View {
        NavigationStack {
            if let session = store.activeSession {
                VStack(spacing: 0) {
                    ExerciseProgressBar(session: session) { index in
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(duration: 0.3)) {
                            store.goToExercise(index: index)
                        }
                    }
                    .padding(.horizontal)

                    TabView(selection: swipeSelection(for: session)) {
                        ForEach(session.exercises.indices, id: \.self) { index in
                            ExercisePage(exerciseIndex: index)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .background(Theme.bg)
                .navigationTitle(session.templateName)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            isPresentingExerciseList = true
                        } label: {
                            Image(systemName: "list.bullet")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 16) {
                            Menu {
                                Button("Cancel Workout", role: .destructive) {
                                    isShowingCancelConfirmation = true
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }

                            Button("Finish") {
                                pendingSummary = WorkoutSummary(session: session)
                            }
                            .fontWeight(.semibold)
                        }
                    }
                }
                .sheet(isPresented: $isPresentingExerciseList) {
                    ExerciseListSheet()
                }
                .sheet(item: $pendingSummary) { summary in
                    WorkoutSummaryView(
                        summary: summary,
                        onDone: {
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            store.finishSession()
                            pendingSummary = nil
                        },
                        onKeepTraining: {
                            pendingSummary = nil
                        }
                    )
                }
                .confirmationDialog(
                    "Cancel this workout?",
                    isPresented: $isShowingCancelConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Discard Workout", role: .destructive) {
                        store.cancelSession()
                    }
                    Button("Keep Going", role: .cancel) {}
                } message: {
                    Text("Nothing logged so far will be saved.")
                }
            } else {
                ContentUnavailableView("No active workout", systemImage: "figure.run")
            }
        }
    }

    private func swipeSelection(for session: WorkoutSession) -> Binding<Int> {
        Binding(
            get: { session.currentExerciseIndex },
            set: { newIndex in
                guard newIndex != session.currentExerciseIndex else { return }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                store.goToExercise(index: newIndex)
            }
        )
    }
}

/// One swipeable page: everything about a single exercise during the session.
private struct ExercisePage: View {
    let exerciseIndex: Int

    @EnvironmentObject private var store: WorkoutStore

    var body: some View {
        if let session = store.activeSession, session.exercises.indices.contains(exerciseIndex) {
            let exercise = session.exercises[exerciseIndex]

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(exercise.exerciseName)
                        .font(.title2.bold())
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    if exercise.targetSets > 0 {
                        Text("Target \(exercise.targetSets) × \(exercise.repRangeLow)–\(exercise.repRangeHigh)")
                            .sectionLabel()
                    }

                    VStack(spacing: 8) {
                        ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { setIndex, set in
                            SetRow(
                                setNumber: setIndex + 1,
                                weight: Binding(
                                    get: { set.weight },
                                    set: { store.updateSet(exerciseIndex: exerciseIndex, setIndex: setIndex, weight: $0, reps: set.reps) }
                                ),
                                reps: Binding(
                                    get: { set.reps },
                                    set: { store.updateSet(exerciseIndex: exerciseIndex, setIndex: setIndex, weight: set.weight, reps: $0) }
                                ),
                                previousWeight: setIndex < exercise.previousWeights.count ? exercise.previousWeights[setIndex] : nil,
                                previousReps: setIndex < exercise.previousReps.count ? exercise.previousReps[setIndex] : nil,
                                isBodyweight: set.isBodyweight,
                                onLog: {
                                    store.logSet(exerciseIndex: exerciseIndex, setIndex: setIndex)
                                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                                }
                            )
                        }

                        Button {
                            store.addSet(toExerciseIndex: exerciseIndex)
                        } label: {
                            Label("Add Set", systemImage: "plus")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textSecondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(Theme.textSecondary.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [6]))
                                )
                        }
                    }

                    ExerciseMediaPlaceholderView()

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes")
                            .sectionLabel()
                        TextEditor(text: notesBinding(for: exercise, templateID: session.templateID))
                            .scrollContentBackground(.hidden)
                            .frame(height: 100)
                            .overlay(alignment: .topLeading) {
                                if (currentEntry(for: exercise, templateID: session.templateID)?.notes ?? "").isEmpty {
                                    Text("Add your own cues, form reminders, how it felt...")
                                        .foregroundStyle(Theme.textSecondary.opacity(0.6))
                                        .padding(.top, 8)
                                        .padding(.leading, 5)
                                        .allowsHitTesting(false)
                                }
                            }
                            .padding(4)
                            .background(Theme.surfaceRaised)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding()
            }
        }
    }

    private func currentEntry(for exercise: SessionExercise, templateID: WorkoutTemplate.ID) -> ExerciseTemplateEntry? {
        store.templates.first(where: { $0.id == templateID })?.exercises.first(where: { $0.exerciseName == exercise.exerciseName })
    }

    private func notesBinding(for exercise: SessionExercise, templateID: WorkoutTemplate.ID) -> Binding<String> {
        Binding(
            get: { currentEntry(for: exercise, templateID: templateID)?.notes ?? "" },
            set: { store.updateNotes($0, forExerciseNamed: exercise.exerciseName, in: templateID) }
        )
    }
}

/// One tappable capsule per exercise: accent = has logged sets, half-accent =
/// current, dim = untouched. Tap to jump, or just swipe the pages below.
private struct ExerciseProgressBar: View {
    let session: WorkoutSession
    let onSelect: (Int) -> Void

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(session.exercises.enumerated()), id: \.element.id) { index, exercise in
                Button {
                    onSelect(index)
                } label: {
                    Capsule()
                        .fill(color(for: exercise, at: index))
                        .frame(height: 6)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: 44)
    }

    private func color(for exercise: SessionExercise, at index: Int) -> Color {
        if exercise.sets.contains(where: { $0.reps != nil }) {
            return Theme.accent
        }
        return index == session.currentExerciseIndex ? Theme.accent.opacity(0.5) : Theme.zoneUnder
    }
}

private struct SetRow: View {
    let setNumber: Int
    @Binding var weight: Double?
    @Binding var reps: Int?
    let previousWeight: Double?
    let previousReps: Int?
    let isBodyweight: Bool
    let onLog: () -> Void

    private var isLogged: Bool { reps != nil }

    var body: some View {
        HStack(spacing: 8) {
            Text("\(setNumber)")
                .font(Theme.numberFont(15))
                .foregroundStyle(Theme.textSecondary)
                .frame(width: 20)

            Text(previousLabel)
                .font(Theme.numberFont(13))
                .monospacedDigit()
                .foregroundStyle(Theme.textSecondary.opacity(0.7))
                .frame(width: 56, alignment: .leading)

            if isBodyweight {
                Text("BW")
                    .font(Theme.numberFont(22))
                    .foregroundStyle(Theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Theme.surfaceRaised.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                numberField(placeholder: previousWeight.map { formatWeight($0, isBodyweight: false) } ?? "lb", text: weightTextBinding)
            }

            numberField(placeholder: previousReps.map(String.init) ?? "reps", text: repsTextBinding)

            Button {
                if !isLogged {
                    onLog()
                }
            } label: {
                Image(systemName: isLogged ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 28))
                    .foregroundStyle(isLogged ? Theme.accent : Theme.textSecondary.opacity(0.5))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
        }
        .animation(.spring(duration: 0.3), value: isLogged)
    }

    private func numberField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(Theme.numberFont(22))
            .monospacedDigit()
            .multilineTextAlignment(.center)
            .keyboardType(.decimalPad)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Theme.surfaceRaised)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(isLogged ? Theme.accent.opacity(0.6) : .clear, lineWidth: 1.5)
            )
    }

    private var previousLabel: String {
        let weightLabel = isBodyweight ? "BW" : previousWeight.map { formatWeight($0, isBodyweight: false) }
        guard let repsValue = previousReps else {
            return weightLabel.map { "\($0)×–" } ?? "–"
        }
        return "\(weightLabel ?? "–")×\(repsValue)"
    }

    private var weightTextBinding: Binding<String> {
        Binding(
            get: { weight.map { formatWeight($0, isBodyweight: false) } ?? "" },
            set: { weight = $0.isEmpty ? nil : Double($0) }
        )
    }

    private var repsTextBinding: Binding<String> {
        Binding(
            get: { reps.map(String.init) ?? "" },
            set: { reps = $0.isEmpty ? nil : Int($0) }
        )
    }
}

private struct ExerciseListSheet: View {
    @EnvironmentObject private var store: WorkoutStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            if let session = store.activeSession {
                List {
                    ForEach(Array(session.exercises.enumerated()), id: \.element.id) { index, exercise in
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(.spring(duration: 0.3)) {
                                store.goToExercise(index: index)
                            }
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(exercise.exerciseName)
                                        .foregroundStyle(Theme.textPrimary)
                                    Text(progressLabel(for: exercise))
                                        .font(.caption)
                                        .foregroundStyle(Theme.textSecondary)
                                }
                                Spacer()
                                if index == session.currentExerciseIndex {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Theme.accent)
                                }
                            }
                        }
                        .listRowBackground(Theme.surface)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Theme.bg)
                .navigationTitle("Exercises")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                    }
                }
            }
        }
    }

    private func progressLabel(for exercise: SessionExercise) -> String {
        guard !exercise.sets.isEmpty else { return "No sets yet" }
        let logged = exercise.sets.filter { $0.reps != nil }.count
        return "\(logged)/\(exercise.sets.count) sets logged"
    }
}

#Preview {
    let store = WorkoutStore()
    store.startSession(from: SeedTemplates.push.id)
    return ActiveWorkoutView()
        .environmentObject(store)
}
