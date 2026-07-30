import SwiftUI

struct WorkoutTabView: View {
    @EnvironmentObject private var store: WorkoutStore

    var body: some View {
        if store.activeSession != nil {
            ActiveWorkoutView()
        } else {
            StartWorkoutPickerView()
        }
    }
}

#Preview {
    WorkoutTabView()
        .environmentObject(WorkoutStore())
}
