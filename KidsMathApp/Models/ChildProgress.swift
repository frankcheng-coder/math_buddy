import Foundation

struct ChildProgress: Codable {
    var totalProblemsAttempted: Int = 0
    var totalCorrect: Int = 0
    var currentStreak: Int = 0
    var bestStreak: Int = 0
    var lastPlayedDate: Date?
    var totalStarsEarned: Int = 0
    var results: [PracticeResult] = []

    // MARK: - Level Progression (Addition & Subtraction)

    var additionLevel: Int = 1
    var subtractionLevel: Int = 1
    var additionQuestionsInLevel: Int = 0
    var subtractionQuestionsInLevel: Int = 0

    static let questionsPerLevel = 10

    func level(for operation: MathOperation) -> Int {
        switch operation {
        case .addition: return additionLevel
        case .subtraction: return subtractionLevel
        default: return 1
        }
    }

    /// Max number for a given level: Level 1 = 10, Level 2 = 20, Level 3 = 30, etc.
    static func maxNumber(forLevel level: Int) -> Int {
        level * 10
    }

    /// Records completed questions and returns true if the child leveled up.
    @discardableResult
    mutating func recordQuestionsCompleted(for operation: MathOperation, count: Int) -> Bool {
        switch operation {
        case .addition:
            additionQuestionsInLevel += count
            if additionQuestionsInLevel >= Self.questionsPerLevel {
                additionQuestionsInLevel -= Self.questionsPerLevel
                additionLevel += 1
                return true
            }
        case .subtraction:
            subtractionQuestionsInLevel += count
            if subtractionQuestionsInLevel >= Self.questionsPerLevel {
                subtractionQuestionsInLevel -= Self.questionsPerLevel
                subtractionLevel += 1
                return true
            }
        default:
            break
        }
        return false
    }

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

    mutating func resetLevels() {
        additionLevel = 1
        subtractionLevel = 1
        additionQuestionsInLevel = 0
        subtractionQuestionsInLevel = 0
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
