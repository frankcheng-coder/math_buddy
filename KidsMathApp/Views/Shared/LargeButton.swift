import SwiftUI

struct LargeButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(color)
                    .shadow(color: color.opacity(0.4), radius: 6, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ThemeCardButton: View {
    let theme: Theme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: theme.iconName)
                    .font(.system(size: 40))
                    .foregroundColor(.white)

                Text(theme.displayName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.cardGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSelected ? Color.white : Color.clear, lineWidth: 4)
                    )
                    .shadow(color: theme.accentColor.opacity(0.4), radius: 8, y: 4)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct AnswerButton: View {
    let number: Int
    let isSelected: Bool
    let isCorrect: Bool?
    let action: () -> Void

    private var backgroundColor: Color {
        guard let isCorrect = isCorrect, isSelected else {
            return Color.blue.opacity(0.15)
        }
        return isCorrect ? .green.opacity(0.3) : .red.opacity(0.3)
    }

    private var borderColor: Color {
        guard let isCorrect = isCorrect, isSelected else {
            return Color.blue.opacity(0.3)
        }
        return isCorrect ? .green : .red
    }

    var body: some View {
        Button(action: action) {
            Text("\(number)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(borderColor, lineWidth: 3)
                        )
                )
        }
        .buttonStyle(.plain)
        .disabled(isSelected && isCorrect != nil)
    }
}
