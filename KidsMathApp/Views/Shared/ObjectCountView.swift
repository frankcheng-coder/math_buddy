import SwiftUI

struct ObjectCountView: View {
    let count: Int
    let theme: Theme
    let maxColumns: Int

    init(count: Int, theme: Theme, maxColumns: Int = 5) {
        self.count = count
        self.theme = theme
        self.maxColumns = maxColumns
    }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: min(count, maxColumns))
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(0..<count, id: \.self) { _ in
                Image(systemName: theme.itemSFSymbol)
                    .font(.system(size: 28))
                    .foregroundColor(theme.accentColor)
            }
        }
        .padding()
    }
}

struct OperatorView: View {
    let symbol: String

    var body: some View {
        Text(symbol)
            .font(.system(size: 40, weight: .bold, design: .rounded))
            .foregroundColor(.primary)
            .frame(width: 50, height: 50)
    }
}

struct EqualsView: View {
    var body: some View {
        Text("=")
            .font(.system(size: 40, weight: .bold, design: .rounded))
            .foregroundColor(.primary)
            .frame(width: 50, height: 50)
    }
}

struct QuestionMarkView: View {
    var body: some View {
        Text("?")
            .font(.system(size: 44, weight: .bold, design: .rounded))
            .foregroundColor(.orange)
            .frame(width: 60, height: 60)
            .background(
                Circle()
                    .fill(Color.orange.opacity(0.15))
            )
    }
}
