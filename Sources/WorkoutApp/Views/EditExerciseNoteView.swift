import SwiftUI

struct EditExerciseNoteView: View {
    let templateID: WorkoutTemplate.ID
    let entry: ExerciseTemplateEntry

    @EnvironmentObject private var store: WorkoutStore
    @Environment(\.dismiss) private var dismiss
    @State private var text: String

    init(templateID: WorkoutTemplate.ID, entry: ExerciseTemplateEntry) {
        self.templateID = templateID
        self.entry = entry
        _text = State(initialValue: entry.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(Theme.bg)
            .navigationTitle(entry.exerciseName)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            store.updateNotes(text, forExercise: entry.id, in: templateID)
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview {
    EditExerciseNoteView(templateID: SeedTemplates.push.id, entry: SeedTemplates.push.exercises[0])
        .environmentObject(WorkoutStore())
}
