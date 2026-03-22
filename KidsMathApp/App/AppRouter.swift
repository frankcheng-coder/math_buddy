import SwiftUI

struct AppRouter: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            HomeView()
        }
        .environmentObject(appState)
    }
}
