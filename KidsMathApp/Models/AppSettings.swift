import Foundation

struct AppSettings: Codable, Equatable {
    var selectedThemeId: String = Theme.cars.id
    var difficulty: DifficultyLevel = .level1
    var enabledOperations: Set<MathOperation> = [.addition, .subtraction]
    var soundEnabled: Bool = true
    var musicEnabled: Bool = false
    var showMultiplication: Bool = true
    var showDivision: Bool = true
    var dailyGoal: Int = 10
    var timerEnabled: Bool = false
    var rewardsEnabled: Bool = true
    var problemsPerSession: Int = 5

    var selectedTheme: Theme {
        Theme(rawValue: selectedThemeId) ?? .cars
    }

    // MARK: - Persistence

    private static let key = "appSettings"

    static func load() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: key),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return AppSettings()
        }
        return settings
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: AppSettings.key)
        }
    }
}
