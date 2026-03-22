import Foundation

struct PracticeResult: Codable, Identifiable {
    let id: UUID
    let operation: MathOperation
    let difficulty: DifficultyLevel
    let totalProblems: Int
    let correctAnswers: Int
    let date: Date
    let themeId: String

    init(operation: MathOperation, difficulty: DifficultyLevel, totalProblems: Int, correctAnswers: Int, themeId: String) {
        self.id = UUID()
        self.operation = operation
        self.difficulty = difficulty
        self.totalProblems = totalProblems
        self.correctAnswers = correctAnswers
        self.date = Date()
        self.themeId = themeId
    }

    var accuracy: Double {
        guard totalProblems > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalProblems)
    }

    var starsEarned: Int {
        switch accuracy {
        case 0.9...1.0: return 3
        case 0.7..<0.9: return 2
        case 0.5..<0.7: return 1
        default: return 0
        }
    }
}
