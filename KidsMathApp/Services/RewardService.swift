import Foundation

class RewardService: ObservableObject {
    static let shared = RewardService()

    static let praiseMessages = [
        "Great job!",
        "Nice counting!",
        "Awesome!",
        "You got it!",
        "Super math work!",
        "Amazing!",
        "Wonderful!",
        "Keep it up!",
        "You're a star!",
        "Fantastic!",
        "Way to go!",
        "Brilliant!"
    ]

    static let encourageMessages = [
        "Almost!",
        "Try again!",
        "You can do it!",
        "So close!",
        "Keep trying!",
        "Good effort!"
    ]

    func randomPraise() -> String {
        Self.praiseMessages.randomElement() ?? "Great job!"
    }

    func randomEncouragement() -> String {
        Self.encourageMessages.randomElement() ?? "Try again!"
    }
}
