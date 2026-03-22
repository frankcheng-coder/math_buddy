import Foundation

enum DifficultyLevel: Int, CaseIterable, Identifiable, Codable {
    case level1 = 1
    case level2 = 2
    case level3 = 3
    case level4 = 4
    case level5 = 5

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .level1: return "Beginner"
        case .level2: return "Easy"
        case .level3: return "Medium"
        case .level4: return "Challenging"
        case .level5: return "Advanced"
        }
    }

    var numberRange: ClosedRange<Int> {
        switch self {
        case .level1: return 0...5
        case .level2: return 0...10
        case .level3: return 0...20
        case .level4: return 1...10
        case .level5: return 1...12
        }
    }

    var enabledOperations: [MathOperation] {
        switch self {
        case .level1: return [.addition]
        case .level2: return [.addition, .subtraction]
        case .level3: return [.addition, .subtraction]
        case .level4: return [.addition, .subtraction, .multiplication]
        case .level5: return [.addition, .subtraction, .multiplication, .division]
        }
    }

    var choiceCount: Int {
        switch self {
        case .level1, .level2: return 3
        case .level3, .level4, .level5: return 4
        }
    }

    var stars: Int {
        switch self {
        case .level1: return 1
        case .level2: return 1
        case .level3: return 2
        case .level4: return 2
        case .level5: return 3
        }
    }

    var description: String {
        switch self {
        case .level1: return "Numbers 0-5, Addition only"
        case .level2: return "Numbers 0-10, Addition & Subtraction"
        case .level3: return "Numbers 0-20, Addition & Subtraction"
        case .level4: return "Early Multiplication"
        case .level5: return "Multiplication & Division"
        }
    }
}
