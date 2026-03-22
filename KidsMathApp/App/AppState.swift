import SwiftUI

class AppState: ObservableObject {
    @Published var selectedTheme: Theme = .cars
    @Published var currentScreen: AppScreen = .home
    @Published var settings: AppSettings = AppSettings.load()
    @Published var progress: ChildProgress = ChildProgress.load()

    func selectTheme(_ theme: Theme) {
        selectedTheme = theme
        settings.selectedThemeId = theme.id
        settings.save()
    }

    func resetProgress() {
        progress = ChildProgress()
        progress.save()
    }
}

enum AppScreen {
    case home
    case themeSelection
    case practice(MathOperation)
    case parentSettings
    case progress
}
