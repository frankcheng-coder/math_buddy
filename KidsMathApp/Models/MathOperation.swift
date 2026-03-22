import SwiftUI

enum MathOperation: String, CaseIterable, Identifiable, Codable {
    case addition
    case subtraction
    case multiplication
    case division

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .addition: return "Addition"
        case .subtraction: return "Subtraction"
        case .multiplication: return "Multiplication"
        case .division: return "Division"
        }
    }

    var symbol: String {
        switch self {
        case .addition: return "+"
        case .subtraction: return "-"
        case .multiplication: return "x"
        case .division: return "/"
        }
    }

    var sfSymbol: String {
        switch self {
        case .addition: return "plus.circle.fill"
        case .subtraction: return "minus.circle.fill"
        case .multiplication: return "multiply.circle.fill"
        case .division: return "divide.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .addition: return .green
        case .subtraction: return .orange
        case .multiplication: return .purple
        case .division: return .pink
        }
    }

    var isAdvanced: Bool {
        self == .multiplication || self == .division
    }
}
