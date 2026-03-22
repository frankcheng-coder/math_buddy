import SwiftUI

struct CelebrationView: View {
    let starsEarned: Int
    let message: String
    let onDismiss: () -> Void

    @State private var showStars = false
    @State private var showMessage = false
    @State private var starScale: CGFloat = 0.1

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 24) {
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: index < starsEarned ? "star.fill" : "star")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                            .scaleEffect(showStars ? 1.0 : 0.1)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.5)
                                    .delay(Double(index) * 0.2),
                                value: showStars
                            )
                    }
                }

                Text(message)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(showMessage ? 1 : 0)
                    .scaleEffect(showMessage ? 1 : 0.5)
                    .animation(.spring(response: 0.4).delay(0.6), value: showMessage)

                Button(action: onDismiss) {
                    Text("Continue")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(Color.green)
                                .shadow(radius: 4)
                        )
                }
                .opacity(showMessage ? 1 : 0)
                .animation(.easeIn.delay(1.0), value: showMessage)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(.ultraThinMaterial)
            )
        }
        .onAppear {
            showStars = true
            showMessage = true
        }
    }
}

struct ConfettiView: View {
    @State private var particles: [(id: Int, x: CGFloat, y: CGFloat, color: Color, size: CGFloat)] = []
    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles, id: \.id) { p in
                    Circle()
                        .fill(p.color)
                        .frame(width: p.size, height: p.size)
                        .position(x: p.x, y: animate ? geo.size.height + 20 : p.y)
                        .animation(
                            .easeIn(duration: Double.random(in: 1.5...3.0))
                                .delay(Double.random(in: 0...0.5)),
                            value: animate
                        )
                }
            }
            .onAppear {
                let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink]
                particles = (0..<30).map { i in
                    (
                        id: i,
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: -50...0),
                        color: colors.randomElement()!,
                        size: CGFloat.random(in: 6...14)
                    )
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animate = true
                }
            }
        }
        .allowsHitTesting(false)
    }
}
