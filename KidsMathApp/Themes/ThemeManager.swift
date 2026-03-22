import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var currentTheme: Theme = .cars

    func apply(_ theme: Theme) {
        currentTheme = theme
    }

    var allThemes: [Theme] {
        Theme.allCases
    }
}
