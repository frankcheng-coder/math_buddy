import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var resetLevelProgress: CGFloat = 0
    @State private var resetLevelTimer: Timer?
    @State private var didResetLevels = false

    var body: some View {
        ZStack {
            appState.selectedTheme.backgroundColor
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    VStack(spacing: 4) {
                        Text("Math Buddy")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(appState.selectedTheme.accentColor)

                        Image(systemName: appState.selectedTheme.iconName)
                            .font(.system(size: 44))
                            .foregroundColor(appState.selectedTheme.secondaryColor)
                    }
                    .padding(.top, 20)

                    // Math Operation Buttons
                    VStack(spacing: 14) {
                        ForEach(MathOperation.allCases) { operation in
                            if shouldShowOperation(operation) {
                                NavigationLink(destination: PracticeView(
                                    operation: operation,
                                    theme: appState.selectedTheme,
                                    difficulty: appState.settings.difficulty,
                                    problemCount: appState.settings.problemsPerSession,
                                    levelMaxNumber: levelMaxNumber(for: operation),
                                    level: operationLevel(for: operation)
                                )) {
                                    OperationCard(
                                        operation: operation,
                                        theme: appState.selectedTheme,
                                        level: operationLevel(for: operation)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    // Bottom Buttons
                    HStack(spacing: 16) {
                        NavigationLink(destination: ThemeSelectionView()) {
                            BottomButton(icon: "paintpalette.fill", label: "Theme", color: appState.selectedTheme.secondaryColor)
                        }

                        NavigationLink(destination: ProgressView_()) {
                            BottomButton(icon: "star.fill", label: "Stars", color: .yellow)
                        }

                        NavigationLink(destination: ParentSettingsView()) {
                            BottomButton(icon: "gearshape.fill", label: "Parent", color: .gray)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                    // Reset Level (long-press protected)
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 44)

                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.orange.opacity(0.5))
                                .frame(width: geo.size.width * resetLevelProgress, height: 44)
                        }
                        .frame(height: 44)

                        Text(didResetLevels ? "Levels Reset!" : "Hold to Reset Levels")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(didResetLevels ? .green : Color.gray)
                    }
                    .gesture(
                        LongPressGesture(minimumDuration: 2.0)
                            .onChanged { _ in startResetLevelTimer() }
                            .onEnded { _ in performResetLevels() }
                    )
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { _ in stopResetLevelTimer() }
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
    }

    private func levelMaxNumber(for operation: MathOperation) -> Int? {
        guard operation == .addition || operation == .subtraction else { return nil }
        let level = appState.progress.level(for: operation)
        return ChildProgress.maxNumber(forLevel: level)
    }

    private func operationLevel(for operation: MathOperation) -> Int? {
        return appState.progress.level(for: operation)
    }

    private func startResetLevelTimer() {
        guard !didResetLevels else { return }
        resetLevelTimer?.invalidate()
        resetLevelProgress = 0
        resetLevelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            withAnimation(.linear(duration: 0.05)) {
                resetLevelProgress += 0.05 / 2.0
            }
            if resetLevelProgress >= 1.0 {
                performResetLevels()
            }
        }
    }

    private func stopResetLevelTimer() {
        resetLevelTimer?.invalidate()
        resetLevelTimer = nil
        if !didResetLevels {
            withAnimation { resetLevelProgress = 0 }
        }
    }

    private func performResetLevels() {
        resetLevelTimer?.invalidate()
        resetLevelTimer = nil
        appState.progress.resetLevels()
        appState.progress.save()
        withAnimation {
            resetLevelProgress = 1.0
            didResetLevels = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                didResetLevels = false
                resetLevelProgress = 0
            }
        }
    }

    private func shouldShowOperation(_ operation: MathOperation) -> Bool {
        switch operation {
        case .addition, .subtraction:
            return appState.settings.enabledOperations.contains(operation)
        case .multiplication:
            return appState.settings.showMultiplication
        case .division:
            return appState.settings.showDivision
        }
    }
}

struct OperationCard: View {
    let operation: MathOperation
    let theme: Theme
    var level: Int? = nil

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: operation.sfSymbol)
                .font(.system(size: 36))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(operation.color)
                )

            Text(operation.displayName)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Spacer()

            if let level = level {
                Text("Lv.\(level)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(operation.color.opacity(0.8))
                    )
            }

            Image(systemName: "chevron.right.circle.fill")
                .font(.title2)
                .foregroundColor(operation.color.opacity(0.6))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
        )
    }

}

struct BottomButton: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        )
    }
}
