import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState

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
                                    problemCount: appState.settings.problemsPerSession
                                )) {
                                    OperationCard(operation: operation, theme: appState.selectedTheme)
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
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
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

            VStack(alignment: .leading, spacing: 2) {
                Text(operation.displayName)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text(operationHint)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right.circle.fill")
                .font(.title2)
                .foregroundColor(operation.color.opacity(0.6))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
        )
    }

    private var operationHint: String {
        switch operation {
        case .addition: return "Put things together"
        case .subtraction: return "Take things away"
        case .multiplication: return "Groups of things"
        case .division: return "Share equally"
        }
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
                .fill(.white)
                .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        )
    }
}
