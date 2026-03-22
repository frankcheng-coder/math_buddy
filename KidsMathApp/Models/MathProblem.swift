import Foundation

struct MathProblem: Identifiable {
    let id = UUID()
    let operand1: Int
    let operand2: Int
    let operation: MathOperation
    let correctAnswer: Int
    let choices: [Int]

    var questionText: String {
        "\(operand1) \(operation.symbol) \(operand2) = ?"
    }

    var totalObjects: Int {
        operand1 + operand2
    }
}
