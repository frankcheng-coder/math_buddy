import SwiftUI

struct PracticeView: View {
    @StateObject private var viewModel: PracticeSessionViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    init(operation: MathOperation, theme: Theme, difficulty: DifficultyLevel, problemCount: Int = 5) {
        _viewModel = StateObject(wrappedValue: PracticeSessionViewModel(
            operation: operation,
            theme: theme,
            difficulty: difficulty,
            totalProblems: problemCount
        ))
    }

    var body: some View {
        ZStack {
            viewModel.theme.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Progress Header
                PracticeHeaderView(
                    progress: viewModel.progressFraction,
                    problemNumber: viewModel.currentProblemIndex + 1,
                    totalProblems: viewModel.totalProblems,
                    theme: viewModel.theme
                )

                Spacer()

                // Visual Problem Display
                ProblemDisplayView(
                    problem: viewModel.currentProblem,
                    theme: viewModel.theme
                )

                Spacer()

                // Answer Choices
                AnswerChoicesView(
                    choices: viewModel.currentProblem.choices,
                    selectedAnswer: viewModel.selectedAnswer,
                    correctAnswer: viewModel.showFeedback ? viewModel.currentProblem.correctAnswer : nil,
                    onSelect: { answer in
                        viewModel.selectAnswer(answer)
                    }
                )

                // Feedback
                if viewModel.showFeedback {
                    FeedbackBannerView(
                        message: viewModel.feedbackMessage,
                        isCorrect: viewModel.isCorrect ?? false,
                        onNext: {
                            viewModel.nextProblem()
                        }
                    )
                }

                Spacer()
            }
            .padding(.horizontal, 20)

            // Session Complete Overlay
            if viewModel.isSessionComplete, let result = viewModel.sessionResult {
                SessionCompleteView(result: result, theme: viewModel.theme) {
                    appState.progress.recordResult(result)
                    appState.progress.save()
                    dismiss()
                }
            }

            // Confetti
            if viewModel.showCelebration {
                ConfettiView()
                    .ignoresSafeArea()
            }
        }
        .navigationBarBackButtonHidden(viewModel.isSessionComplete)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PracticeHeaderView: View {
    let progress: Double
    let problemNumber: Int
    let totalProblems: Int
    let theme: Theme

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(problemNumber) / \(totalProblems)")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                Spacer()
            }

            ProgressBar(value: progress, color: theme.accentColor)
        }
        .padding(.top, 8)
    }
}

struct ProblemDisplayView: View {
    let problem: MathProblem
    let theme: Theme

    var body: some View {
        VStack(spacing: 16) {
            // Visual objects
            HStack(spacing: 12) {
                ObjectCountView(count: min(problem.operand1, 10), theme: theme, maxColumns: 5)

                OperatorView(symbol: problem.operation.symbol)

                ObjectCountView(count: min(problem.operand2, 10), theme: theme, maxColumns: 5)
            }

            // Equation text
            HStack(spacing: 8) {
                Text("\(problem.operand1)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))

                Text(problem.operation.symbol)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(problem.operation.color)

                Text("\(problem.operand2)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))

                EqualsView()

                QuestionMarkView()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white.opacity(0.8))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        )
    }
}

struct AnswerChoicesView: View {
    let choices: [Int]
    let selectedAnswer: Int?
    let correctAnswer: Int?
    let onSelect: (Int) -> Void

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: min(choices.count, 2))

        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(choices, id: \.self) { choice in
                AnswerButton(
                    number: choice,
                    isSelected: selectedAnswer == choice,
                    isCorrect: answerState(for: choice)
                ) {
                    onSelect(choice)
                }
            }
        }
    }

    private func answerState(for choice: Int) -> Bool? {
        guard let correctAnswer = correctAnswer else { return nil }
        if selectedAnswer == choice {
            return choice == correctAnswer
        }
        if choice == correctAnswer {
            return true
        }
        return nil
    }
}

struct FeedbackBannerView: View {
    let message: String
    let isCorrect: Bool
    let onNext: () -> Void

    @State private var appear = false

    var body: some View {
        HStack {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "arrow.uturn.right.circle.fill")
                .font(.title2)
                .foregroundColor(isCorrect ? .green : .orange)

            Text(message)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(isCorrect ? .green : .orange)

            Spacer()

            Button(action: onNext) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(isCorrect ? .green : .orange)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isCorrect ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
        )
        .scaleEffect(appear ? 1.0 : 0.8)
        .opacity(appear ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.3)) {
                appear = true
            }
        }
        .onDisappear { appear = false }
    }
}

struct SessionCompleteView: View {
    let result: PracticeResult
    let theme: Theme
    let onDismiss: () -> Void

    var body: some View {
        CelebrationView(
            starsEarned: result.starsEarned,
            message: completionMessage
        ) {
            onDismiss()
        }
    }

    private var completionMessage: String {
        switch result.accuracy {
        case 0.9...1.0: return "Amazing!"
        case 0.7..<0.9: return "Great job!"
        case 0.5..<0.7: return "Good try!"
        default: return "Keep practicing!"
        }
    }
}
