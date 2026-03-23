import SwiftUI

struct PracticeView: View {
    @StateObject private var viewModel: PracticeSessionViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    init(operation: MathOperation, theme: Theme, difficulty: DifficultyLevel, problemCount: Int = 10, levelMaxNumber: Int? = nil, level: Int? = nil) {
        _viewModel = StateObject(wrappedValue: PracticeSessionViewModel(
            operation: operation,
            theme: theme,
            difficulty: difficulty,
            totalProblems: problemCount,
            levelMaxNumber: levelMaxNumber,
            level: level
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

            // Level-Up Overlay (shown first, then session complete)
            if viewModel.didLevelUp {
                LevelUpView(level: viewModel.newLevel, operation: viewModel.operation, theme: viewModel.theme) {
                    viewModel.didLevelUp = false
                }
            }

            // Session Complete Overlay
            if viewModel.isSessionComplete && !viewModel.didLevelUp, let result = viewModel.sessionResult {
                SessionCompleteView(result: result, theme: viewModel.theme) {
                    dismiss()
                }
            }

            // Confetti
            if viewModel.showCelebration || viewModel.didLevelUp {
                ConfettiView()
                    .ignoresSafeArea()
            }
        }
        .navigationBarBackButtonHidden(viewModel.isSessionComplete)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.isSessionComplete) { _, isComplete in
            guard isComplete, let result = viewModel.sessionResult else { return }
            appState.progress.recordResult(result)
            viewModel.checkLevelUp(progress: &appState.progress)
            appState.progress.save()
        }
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
            // Visual objects — layout varies by operation
            visualObjectsView

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

    @ViewBuilder
    private var visualObjectsView: some View {
        switch problem.operation {
        case .multiplication:
            // Show as repeated groups: e.g. 3 x 2 = three groups of 2 objects
            VStack(spacing: 6) {
                Text("\(problem.operand1) groups of \(problem.operand2)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                HStack(spacing: 10) {
                    ForEach(0..<min(problem.operand1, 6), id: \.self) { _ in
                        VStack(spacing: 4) {
                            ForEach(0..<min(problem.operand2, 5), id: \.self) { _ in
                                Image(systemName: theme.itemSFSymbol)
                                    .font(.system(size: 20))
                                    .foregroundColor(theme.accentColor)
                            }
                        }
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(theme.accentColor.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [4]))
                        )
                    }
                }
            }
        case .division:
            // Show as sharing: e.g. 6 ÷ 2 = 6 objects shared into 2 groups
            VStack(spacing: 6) {
                Text("Share \(problem.operand1) into \(problem.operand2) groups")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                HStack(spacing: 4) {
                    ForEach(0..<min(problem.operand1, 12), id: \.self) { _ in
                        Image(systemName: theme.itemSFSymbol)
                            .font(.system(size: 20))
                            .foregroundColor(theme.accentColor)
                    }
                }
                Image(systemName: "arrow.down")
                    .font(.title3)
                    .foregroundColor(.secondary)
                HStack(spacing: 10) {
                    ForEach(0..<min(problem.operand2, 5), id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(theme.accentColor.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [4]))
                            .frame(width: 50, height: 40)
                            .overlay(
                                Text("?")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.orange)
                            )
                    }
                }
            }
        default:
            // Addition / Subtraction: original layout
            HStack(spacing: 12) {
                ObjectCountView(count: problem.operand1, theme: theme, maxColumns: 5)
                OperatorView(symbol: problem.operation.symbol)
                ObjectCountView(count: problem.operand2, theme: theme, maxColumns: 5)
            }
        }
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
    @State private var pulseArrow = false

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
                    .scaleEffect(pulseArrow ? 1.35 : 1.0)
                    .shadow(color: pulseArrow ? (isCorrect ? .green.opacity(0.5) : .orange.opacity(0.5)) : .clear, radius: 8)
                    .animation(
                        .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                        value: pulseArrow
                    )
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                pulseArrow = true
            }
        }
        .onDisappear { appear = false; pulseArrow = false }
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

struct LevelUpView: View {
    let level: Int
    let operation: MathOperation
    let theme: Theme
    let onDismiss: () -> Void

    @State private var showBadge = false
    @State private var showText = false

    private var levelDescription: String {
        switch operation {
        case .addition, .subtraction:
            return "Numbers up to \(ChildProgress.maxNumber(forLevel: level))!"
        case .multiplication:
            let maxA = min(level + 1, 9)
            let maxB = min(level + 2, 9)
            return "Up to \(maxA) × \(maxB)!"
        case .division:
            let maxAnswer = min(level + 1, 9)
            let maxDivisor = min(level + 1, 6)
            return "Answers up to \(maxAnswer), ÷ up to \(maxDivisor)!"
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.yellow)
                    .scaleEffect(showBadge ? 1.0 : 0.1)
                    .animation(.spring(response: 0.5, dampingFraction: 0.5), value: showBadge)

                Text("Level Up!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(showText ? 1 : 0)
                    .animation(.easeIn.delay(0.4), value: showText)

                Text("\(operation.displayName) Level \(level)")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .opacity(showText ? 1 : 0)
                    .animation(.easeIn.delay(0.6), value: showText)

                Text(levelDescription)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .opacity(showText ? 1 : 0)
                    .animation(.easeIn.delay(0.8), value: showText)

                Button(action: onDismiss) {
                    Text("Keep Going!")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(operation.color)
                                .shadow(radius: 4)
                        )
                }
                .opacity(showText ? 1 : 0)
                .animation(.easeIn.delay(1.0), value: showText)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(.ultraThinMaterial)
            )
        }
        .onAppear {
            showBadge = true
            showText = true
        }
    }
}
