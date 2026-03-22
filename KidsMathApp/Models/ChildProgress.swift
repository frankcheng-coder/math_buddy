import Foundation

struct ChildProgress: Codable {
    var totalProblemsAttempted: Int = 0
    var totalCorrect: Int = 0
    var currentStreak: Int = 0
    var bestStreak: Int = 0
    var lastPlayedDate: Date?
    var totalStarsEarned: Int = 0
    var results: [PracticeResult] = []

    var overallAccuracy: Double {
        guard totalProblemsAttempted > 0 else { return 0 }
        return Double(totalCorrect) / Double(totalProblemsAttempted)
    }

    func accuracy(for operation: MathOperation) -> Double {
        let relevant = results.filter { $0.operation == operation }
        let total = relevant.reduce(0) { $0 + $1.totalProblems }
        let correct = relevant.reduce(0) { $0 + $1.correctAnswers }
        guard total > 0 else { return 0 }
        return Double(correct) / Double(total)
    }

    func totalProblems(for operation: MathOperation) -> Int {
        results.filter { $0.operation == operation }.reduce(0) { $0 + $1.totalProblems }
    }

    mutating func recordResult(_ result: PracticeResult) {
        results.append(result)
        totalProblemsAttempted += result.totalProblems
        totalCorrect += result.correctAnswers
        totalStarsEarned += result.starsEarned
        lastPlayedDate = Date()
    }

    mutating func recordCorrectAnswer() {
        currentStreak += 1
        if currentStreak > bestStreak {
            bestStreak = currentStreak
        }
    }

    mutating func recordWrongAnswer() {
        currentStreak = 0
    }

    // MARK: - Persistence

    private static let key = "childProgress"

    static func load() -> ChildProgress {
        guard let data = UserDefaults.standard.data(forKey: key),
              let progress = try? JSONDecoder().decode(ChildProgress.self, from: data) else {
            return ChildProgress()
        }
        return progress
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: ChildProgress.key)
        }
    }
}
