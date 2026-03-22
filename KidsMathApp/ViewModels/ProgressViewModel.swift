import SwiftUI

class ProgressViewModel: ObservableObject {
    @Published var progress: ChildProgress

    init(progress: ChildProgress) {
        self.progress = progress
    }

    var totalStars: Int { progress.totalStarsEarned }
    var bestStreak: Int { progress.bestStreak }
    var totalProblems: Int { progress.totalProblemsAttempted }

    func accuracyPercent(for operation: MathOperation) -> Int {
        Int(progress.accuracy(for: operation) * 100)
    }
}
