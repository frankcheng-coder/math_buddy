import SwiftUI

class PracticeSessionViewModel: ObservableObject {
    let operation: MathOperation
    let theme: Theme
    let difficulty: DifficultyLevel
    let totalProblems: Int
    let levelMaxNumber: Int?
    let level: Int?

    private let engine: MathEngine
    private let audioService = AudioService.shared
    private let rewardService = RewardService.shared
    private var usedQuestions: Set<String> = []

    @Published var currentProblem: MathProblem
    @Published var currentProblemIndex: Int = 0
    @Published var correctCount: Int = 0
    @Published var selectedAnswer: Int?
    @Published var isCorrect: Bool?
    @Published var showFeedback: Bool = false
    @Published var feedbackMessage: String = ""
    @Published var isSessionComplete: Bool = false
    @Published var sessionResult: PracticeResult?
    @Published var showCelebration: Bool = false
    @Published var didLevelUp: Bool = false
    @Published var newLevel: Int = 0

    init(operation: MathOperation, theme: Theme, difficulty: DifficultyLevel, totalProblems: Int = 5, levelMaxNumber: Int? = nil, level: Int? = nil) {
        self.operation = operation
        self.theme = theme
        self.difficulty = difficulty
        self.totalProblems = totalProblems
        self.levelMaxNumber = levelMaxNumber
        self.level = level
        self.engine = MathEngineFactory.engine(for: operation)
        self.currentProblem = Self.generateFirst(engine: engine, difficulty: difficulty, levelMaxNumber: levelMaxNumber, level: level)
        self.usedQuestions.insert(Self.questionKey(currentProblem))
    }

    private static func questionKey(_ p: MathProblem) -> String {
        "\(p.operand1)\(p.operation.symbol)\(p.operand2)"
    }

    private static func generateFirst(engine: MathEngine, difficulty: DifficultyLevel, levelMaxNumber: Int?, level: Int?) -> MathProblem {
        if let max = levelMaxNumber {
            if let addEngine = engine as? AdditionEngine {
                return addEngine.generateProblem(maxNumber: max)
            } else if let subEngine = engine as? SubtractionEngine {
                return subEngine.generateProblem(maxNumber: max)
            }
        }
        if let lvl = level {
            if let mulEngine = engine as? MultiplicationEngine {
                return mulEngine.generateProblem(level: lvl)
            } else if let divEngine = engine as? DivisionEngine {
                return divEngine.generateProblem(level: lvl)
            }
        }
        return engine.generateProblem(difficulty: difficulty)
    }

    func selectAnswer(_ answer: Int) {
        guard selectedAnswer == nil else { return }
        selectedAnswer = answer
        let correct = answer == currentProblem.correctAnswer
        isCorrect = correct

        if correct {
            correctCount += 1
            feedbackMessage = rewardService.randomPraise()
            audioService.playCorrectSound()
        } else {
            feedbackMessage = rewardService.randomEncouragement()
            audioService.playWrongSound()
        }

        showFeedback = true
    }

    func nextProblem() {
        guard !isSessionComplete else { return }

        let nextIndex = currentProblemIndex + 1
        if nextIndex >= totalProblems {
            currentProblemIndex = totalProblems - 1
            completeSession()
            return
        }

        currentProblemIndex = nextIndex

        selectedAnswer = nil
        isCorrect = nil
        showFeedback = false
        feedbackMessage = ""
        currentProblem = generateNextProblem()
    }

    private func generateNextProblem() -> MathProblem {
        // Try up to 20 times to avoid repeating a question within this session
        for _ in 0..<20 {
            let problem = generateRawProblem()
            let key = Self.questionKey(problem)
            if !usedQuestions.contains(key) {
                usedQuestions.insert(key)
                return problem
            }
        }
        // Fallback: all unique combinations exhausted, allow repeat
        let problem = generateRawProblem()
        usedQuestions.insert(Self.questionKey(problem))
        return problem
    }

    private func generateRawProblem() -> MathProblem {
        if let max = levelMaxNumber {
            if let addEngine = engine as? AdditionEngine {
                return addEngine.generateProblem(maxNumber: max)
            } else if let subEngine = engine as? SubtractionEngine {
                return subEngine.generateProblem(maxNumber: max)
            }
        }
        if let lvl = level {
            if let mulEngine = engine as? MultiplicationEngine {
                return mulEngine.generateProblem(level: lvl)
            } else if let divEngine = engine as? DivisionEngine {
                return divEngine.generateProblem(level: lvl)
            }
        }
        return engine.generateProblem(difficulty: difficulty)
    }

    private func completeSession() {
        let result = PracticeResult(
            operation: operation,
            difficulty: difficulty,
            totalProblems: totalProblems,
            correctAnswers: correctCount,
            themeId: theme.id
        )
        sessionResult = result
        isSessionComplete = true
        showCelebration = true
        audioService.playCelebrationSound()
    }

    /// Called by the view after recording the result to check for level-up.
    func checkLevelUp(progress: inout ChildProgress) {
        let leveled = progress.recordQuestionsCompleted(for: operation, count: totalProblems)
        if leveled {
            didLevelUp = true
            newLevel = progress.level(for: operation)
            audioService.playCelebrationSound()
        }
    }

    var progressFraction: Double {
        min(Double(currentProblemIndex + 1) / Double(totalProblems), 1.0)
    }
}
