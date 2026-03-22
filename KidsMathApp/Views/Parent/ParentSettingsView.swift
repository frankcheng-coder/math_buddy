import SwiftUI

struct ParentSettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var isUnlocked = false
    @State private var holdProgress: CGFloat = 0
    @State private var holdTimer: Timer?
    @State private var showResetConfirm = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            if isUnlocked {
                settingsContent
            } else {
                parentGateView
            }
        }
        .navigationTitle("Parent Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var parentGateView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "lock.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("Hold the button to unlock")
                .font(.title3)
                .foregroundColor(.secondary)

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: holdProgress)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.blue)
            }
            .gesture(
                LongPressGesture(minimumDuration: 3.0)
                    .onChanged { _ in
                        startHoldTimer()
                    }
                    .onEnded { _ in
                        withAnimation { isUnlocked = true }
                    }
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { _ in
                        stopHoldTimer()
                    }
            )

            Spacer()
        }
    }

    @ViewBuilder
    private var settingsContent: some View {
        Form {
            Section("Difficulty") {
                Picker("Level", selection: $appState.settings.difficulty) {
                    ForEach(DifficultyLevel.allCases) { level in
                        VStack(alignment: .leading) {
                            Text(level.displayName)
                            Text(level.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .tag(level)
                    }
                }

                Stepper("Problems per session: \(appState.settings.problemsPerSession)",
                        value: $appState.settings.problemsPerSession, in: 3...20)
            }

            Section("Math Operations") {
                Toggle("Addition", isOn: Binding(
                    get: { appState.settings.enabledOperations.contains(.addition) },
                    set: { if $0 { appState.settings.enabledOperations.insert(.addition) }
                        else { appState.settings.enabledOperations.remove(.addition) } }
                ))

                Toggle("Subtraction", isOn: Binding(
                    get: { appState.settings.enabledOperations.contains(.subtraction) },
                    set: { if $0 { appState.settings.enabledOperations.insert(.subtraction) }
                        else { appState.settings.enabledOperations.remove(.subtraction) } }
                ))

                Toggle("Show Multiplication", isOn: $appState.settings.showMultiplication)
                Toggle("Show Division", isOn: $appState.settings.showDivision)
            }

            Section("Audio") {
                Toggle("Sound Effects", isOn: Binding(
                    get: { appState.settings.soundEnabled },
                    set: {
                        appState.settings.soundEnabled = $0
                        AudioService.shared.isSoundEnabled = $0
                    }
                ))
                Toggle("Background Music", isOn: $appState.settings.musicEnabled)
            }

            Section("Rewards") {
                Toggle("Rewards Enabled", isOn: $appState.settings.rewardsEnabled)
                Stepper("Daily Goal: \(appState.settings.dailyGoal) problems",
                        value: $appState.settings.dailyGoal, in: 5...50, step: 5)
            }

            Section("Data") {
                Button("Reset All Progress", role: .destructive) {
                    showResetConfirm = true
                }
                .alert("Reset Progress?", isPresented: $showResetConfirm) {
                    Button("Cancel", role: .cancel) { }
                    Button("Reset", role: .destructive) {
                        appState.resetProgress()
                    }
                } message: {
                    Text("This will erase all stars, streaks, and practice history.")
                }
            }
        }
        .onChange(of: appState.settings) { _, _ in
            appState.settings.save()
        }
    }

    private func startHoldTimer() {
        holdTimer?.invalidate()
        holdProgress = 0
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            withAnimation(.linear(duration: 0.05)) {
                holdProgress += 0.05 / 3.0
            }
            if holdProgress >= 1.0 {
                stopHoldTimer()
                withAnimation { isUnlocked = true }
            }
        }
    }

    private func stopHoldTimer() {
        holdTimer?.invalidate()
        holdTimer = nil
        withAnimation { holdProgress = 0 }
    }
}
