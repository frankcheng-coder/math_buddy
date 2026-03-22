import SwiftUI

class ParentSettingsViewModel: ObservableObject {
    @Published var settings: AppSettings
    @Published var isUnlocked: Bool = false

    init(settings: AppSettings) {
        self.settings = settings
    }

    func saveSettings() {
        settings.save()
    }

    func toggleOperation(_ operation: MathOperation) {
        if settings.enabledOperations.contains(operation) {
            settings.enabledOperations.remove(operation)
        } else {
            settings.enabledOperations.insert(operation)
        }
        saveSettings()
    }
}
