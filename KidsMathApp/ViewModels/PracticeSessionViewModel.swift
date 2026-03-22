import SwiftUI

class PracticeSessionViewModel: ObservableObject {
    let operation: MathOperation
    let theme: Theme
    let difficulty: DifficultyLevel
    let totalProblems: Int

    private let engine: MathEngine
    private let audioService = AudioService.shared
    private let rewardService = RewardService.shared

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

    init(operation: MathOperation, theme: Theme, difficulty: DifficultyLevel, totalProblems: Int = 5) {
        self.operation = operation
        self.theme = theme
        self.difficulty = difficulty
        self.totalProblems = totalProblems
        self.engine = MathEngineFactory.engine(for: operation)
        self.currentProblem = engine.generateProblem(difficulty: difficulty)
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
        currentProblemIndex += 1

        if currentProblemIndex >= totalProblems {
            completeSession()
            return
        }

        selectedAnswer = nil
        isCorrect = nil
        showFeedback = false
        feedbackMessage = ""
        currentProblem = engine.generateProblem(difficulty: difficulty)
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

    var progressFraction: Double {
        Double(currentProblemIndex) / Double(totalProblems)
    }
}
