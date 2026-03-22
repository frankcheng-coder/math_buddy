import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var availableOperations: [MathOperation] = MathOperation.allCases

    func isOperationEnabled(_ operation: MathOperation, settings: AppSettings) -> Bool {
        if operation.isAdvanced {
            if operation == .multiplication { return settings.showMultiplication }
            if operation == .division { return settings.showDivision }
        }
        return settings.enabledOperations.contains(operation)
    }
}
