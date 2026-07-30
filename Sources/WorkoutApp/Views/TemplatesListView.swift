import SwiftUI

struct TemplatesListView: View {
    @EnvironmentObject private var store: WorkoutStore
    @State private var isPresentingAddTemplate = false
    @State private var path: [WorkoutTemplate.ID] = []

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(store.templates) { template in
                    NavigationLink(value: template.id) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(template.name)
                                .font(.title3.bold())
                                .foregroundStyle(Theme.textPrimary)
                            Text(exerciseCountLabel(template.exercises.count))
                                .font(.subheadline)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .themeCard()
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                }
                .onDelete(perform: store.deleteTemplates)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
            .navigationTitle("Templates")
            .navigationDestination(for: WorkoutTemplate.ID.self) { templateID in
                TemplateDetailView(templateID: templateID)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresentingAddTemplate = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddTemplate) {
                AddTemplateView { newTemplateID in
                    path.append(newTemplateID)
                }
            }
        }
    }
}

func exerciseCountLabel(_ count: Int) -> String {
    "\(count) exercise\(count == 1 ? "" : "s")"
}

#Preview {
    TemplatesListView()
        .environmentObject(WorkoutStore())
}
