import SwiftUI

enum Theme: String, CaseIterable, Identifiable, Codable {
    case cars
    case animals
    case plants

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cars: return "Cars"
        case .animals: return "Animals"
        case .plants: return "Plants"
        }
    }

    var itemEmoji: String {
        switch self {
        case .cars: return "car.fill"
        case .animals: return "pawprint.fill"
        case .plants: return "leaf.fill"
        }
    }

    var itemSFSymbol: String {
        switch self {
        case .cars: return "car.fill"
        case .animals: return "pawprint.fill"
        case .plants: return "leaf.fill"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .cars: return Color(red: 0.9, green: 0.95, blue: 1.0)
        case .animals: return Color(red: 1.0, green: 0.96, blue: 0.9)
        case .plants: return Color(red: 0.9, green: 1.0, blue: 0.92)
        }
    }

    var accentColor: Color {
        switch self {
        case .cars: return .blue
        case .animals: return .orange
        case .plants: return .green
        }
    }

    var secondaryColor: Color {
        switch self {
        case .cars: return Color(red: 0.3, green: 0.5, blue: 0.9)
        case .animals: return Color(red: 0.9, green: 0.6, blue: 0.2)
        case .plants: return Color(red: 0.3, green: 0.7, blue: 0.4)
        }
    }

    var sceneDescription: String {
        switch self {
        case .cars: return "garage"
        case .animals: return "field"
        case .plants: return "garden"
        }
    }

    var objectName: String {
        switch self {
        case .cars: return "car"
        case .animals: return "animal"
        case .plants: return "flower"
        }
    }

    var objectNamePlural: String {
        switch self {
        case .cars: return "cars"
        case .animals: return "animals"
        case .plants: return "flowers"
        }
    }

    var iconName: String {
        switch self {
        case .cars: return "car.fill"
        case .animals: return "hare.fill"
        case .plants: return "leaf.fill"
        }
    }

    var cardGradient: LinearGradient {
        LinearGradient(
            colors: [accentColor.opacity(0.7), secondaryColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
