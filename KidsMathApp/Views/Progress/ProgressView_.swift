import SwiftUI
import UIKit

struct ProgressView_: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            appState.selectedTheme.backgroundColor
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Stars Header
                    VStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)

                        Text("\(appState.progress.totalStarsEarned)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)

                        Text("Stars Earned")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 16)

                    // Stats Cards
                    HStack(spacing: 12) {
                        StatCard(
                            icon: "flame.fill",
                            value: "\(appState.progress.bestStreak)",
                            label: "Best Streak",
                            color: .orange
                        )

                        StatCard(
                            icon: "checkmark.circle.fill",
                            value: "\(appState.progress.totalProblemsAttempted)",
                            label: "Problems",
                            color: .blue
                        )

                        StatCard(
                            icon: "percent",
                            value: "\(Int(appState.progress.overallAccuracy * 100))%",
                            label: "Accuracy",
                            color: .green
                        )
                    }
                    .padding(.horizontal, 20)

                    // Operation Breakdown
                    VStack(spacing: 12) {
                        Text("Skills")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(MathOperation.allCases) { op in
                            SkillRow(
                                operation: op,
                                accuracy: appState.progress.accuracy(for: op),
                                totalProblems: appState.progress.totalProblems(for: op)
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                    // Recent Sessions
                    if !appState.progress.results.isEmpty {
                        VStack(spacing: 12) {
                            Text("Recent Sessions")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            ForEach(appState.progress.results.suffix(5).reversed()) { result in
                                RecentSessionRow(result: result)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        )
    }
}

struct SkillRow: View {
    let operation: MathOperation
    let accuracy: Double
    let totalProblems: Int

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: operation.sfSymbol)
                .font(.title3)
                .foregroundColor(operation.color)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(operation.displayName)
                    .font(.system(size: 16, weight: .semibold))

                ProgressBar(value: accuracy, color: operation.color)
            }

            Text("\(Int(accuracy * 100))%")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .frame(width: 44, alignment: .trailing)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
        )
    }
}

struct RecentSessionRow: View {
    let result: PracticeResult

    var body: some View {
        HStack {
            Image(systemName: result.operation.sfSymbol)
                .foregroundColor(result.operation.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(result.operation.displayName)
                    .font(.subheadline.bold())
                Text("\(result.correctAnswers)/\(result.totalProblems) correct")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            StarRatingView(count: result.starsEarned, size: 14)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
        )
    }
}
