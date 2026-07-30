import SwiftUI

struct AddTemplateView: View {
    /// Called with the new template's id so the caller can push its detail view.
    var onCreate: (WorkoutTemplate.ID) -> Void = { _ in }

    @EnvironmentObject private var store: WorkoutStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var category: ExerciseCategory?
    @State private var categoryWasSetManually = false

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    /// Wraps `category` so choosing from the picker stops the name-based guess
    /// from overwriting the choice on the next keystroke.
    private var categorySelection: Binding<ExerciseCategory?> {
        Binding(
            get: { category },
            set: { newValue in
                category = newValue
                categoryWasSetManually = true
            }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Template name (e.g. Push)", text: $name)
                }

                Section {
                    Picker("Type", selection: categorySelection) {
                        Text("Any").tag(ExerciseCategory?.none)
                        ForEach(ExerciseCategory.allCases) { option in
                            Text(option.displayName).tag(ExerciseCategory?.some(option))
                        }
                    }
                } header: {
                    Text("Workout type")
                } footer: {
                    Text("Picking a type pre-filters the exercise list to matching exercises when you add them.")
                }
            }
            .navigationTitle("New Template")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let id = store.addTemplate(name: trimmedName, category: category)
                        dismiss()
                        onCreate(id)
                    }
                    .disabled(trimmedName.isEmpty)
                }
            }
            .onChange(of: name) {
                guessCategoryFromName()
            }
        }
    }

    /// Typing "Push" almost certainly means a push day — save the user a tap,
    /// but only until they pick something themselves.
    private func guessCategoryFromName() {
        guard !categoryWasSetManually else { return }
        category = ExerciseCategory.inferred(fromTemplateName: trimmedName)
    }
}

#Preview {
    AddTemplateView()
        .environmentObject(WorkoutStore())
}
