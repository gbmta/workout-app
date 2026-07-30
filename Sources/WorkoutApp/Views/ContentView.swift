import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: WorkoutStore

    var body: some View {
        TabView(selection: $store.selectedTab) {
            TemplatesListView()
                .tabItem {
                    Label("Templates", systemImage: "list.bullet.rectangle")
                }
                .tag(AppTab.templates)

            WorkoutTabView()
                .tabItem {
                    Label("Workout", systemImage: "figure.strengthtraining.traditional")
                }
                .tag(AppTab.workout)

            VolumeTrackerView()
                .tabItem {
                    Label("Volume", systemImage: "chart.bar")
                }
                .tag(AppTab.volume)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WorkoutStore())
}
