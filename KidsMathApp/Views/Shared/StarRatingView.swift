import SwiftUI

struct StarRatingView: View {
    let count: Int
    let maxStars: Int
    let size: CGFloat

    init(count: Int, maxStars: Int = 3, size: CGFloat = 24) {
        self.count = count
        self.maxStars = maxStars
        self.size = size
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<maxStars, id: \.self) { index in
                Image(systemName: index < count ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundColor(.yellow)
            }
        }
    }
}

struct ProgressBar: View {
    let value: Double
    let color: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))

                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(width: geo.size.width * max(0, min(value, 1.0)))
            }
        }
        .frame(height: 12)
    }
}
