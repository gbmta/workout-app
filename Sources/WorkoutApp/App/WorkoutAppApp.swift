import SwiftUI

@main
struct WorkoutAppApp: App {
    @StateObject private var store = WorkoutStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .tint(Theme.accent)
                .background(Theme.bg)
        }
    }
}
