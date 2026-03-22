import SwiftUI

struct ThemeSelectionView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            appState.selectedTheme.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Choose a Theme")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(appState.selectedTheme.accentColor)
                    .padding(.top, 16)

                VStack(spacing: 16) {
                    ForEach(Theme.allCases) { theme in
                        ThemeCardButton(
                            theme: theme,
                            isSelected: appState.selectedTheme == theme
                        ) {
                            appState.selectTheme(theme)
                            AudioService.shared.playTapSound()
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
