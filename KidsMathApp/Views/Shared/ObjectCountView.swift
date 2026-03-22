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

    /// Icon size scales down as count grows so everything fits.
    private var iconSize: CGFloat {
        if count <= 5 { return 28 }
        if count <= 10 { return 22 }
        if count <= 20 { return 16 }
        return 14
    }

    /// Spacing shrinks with icon size.
    private var gridSpacing: CGFloat {
        count <= 10 ? 6 : 4
    }

    private var columns: [GridItem] {
        let cols = min(count, maxColumns)
        return Array(repeating: GridItem(.flexible(), spacing: gridSpacing), count: max(cols, 1))
    }

    var body: some View {
        if count <= 10 {
            // Direct rendering — current behavior
            LazyVGrid(columns: columns, spacing: gridSpacing) {
                ForEach(0..<count, id: \.self) { _ in
                    Image(systemName: theme.itemSFSymbol)
                        .font(.system(size: iconSize))
                        .foregroundColor(theme.accentColor)
                }
            }
            .padding(8)
        } else {
            // Grouped rendering: rows of 5 with a numeric label
            VStack(spacing: 4) {
                let fullRows = count / maxColumns
                let remainder = count % maxColumns

                ForEach(0..<fullRows, id: \.self) { _ in
                    HStack(spacing: gridSpacing) {
                        ForEach(0..<maxColumns, id: \.self) { _ in
                            Image(systemName: theme.itemSFSymbol)
                                .font(.system(size: iconSize))
                                .foregroundColor(theme.accentColor)
                        }
                    }
                }

                if remainder > 0 {
                    HStack(spacing: gridSpacing) {
                        ForEach(0..<remainder, id: \.self) { _ in
                            Image(systemName: theme.itemSFSymbol)
                                .font(.system(size: iconSize))
                                .foregroundColor(theme.accentColor)
                        }
                    }
                }

                Text("\(count)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(theme.accentColor.opacity(0.7))
            }
            .padding(8)
        }
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
