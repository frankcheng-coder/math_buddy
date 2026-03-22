import Foundation

protocol MathEngine {
    var operation: MathOperation { get }
    func generateProblem(difficulty: DifficultyLevel) -> MathProblem
}

extension MathEngine {
    func generateChoices(correctAnswer: Int, count: Int, range: ClosedRange<Int>) -> [Int] {
        var choices = Set<Int>()
        choices.insert(correctAnswer)

        let minChoice = max(0, correctAnswer - 5)
        let maxChoice = correctAnswer + 5

        while choices.count < count {
            let wrong = Int.random(in: minChoice...maxChoice)
            if wrong >= 0 {
                choices.insert(wrong)
            }
        }

        return Array(choices).shuffled()
    }
}

struct AdditionEngine: MathEngine {
    let operation = MathOperation.addition

    func generateProblem(difficulty: DifficultyLevel) -> MathProblem {
        let range = difficulty.numberRange
        let a = Int.random(in: range)
        let b = Int.random(in: range)
        let answer = a + b
        let choices = generateChoices(correctAnswer: answer, count: difficulty.choiceCount, range: range)
        return MathProblem(operand1: a, operand2: b, operation: .addition, correctAnswer: answer, choices: choices)
    }
}

struct SubtractionEngine: MathEngine {
    let operation = MathOperation.subtraction

    func generateProblem(difficulty: DifficultyLevel) -> MathProblem {
        let range = difficulty.numberRange
        var a = Int.random(in: range)
        var b = Int.random(in: range)
        // Ensure a >= b so result is non-negative
        if a < b { swap(&a, &b) }
        let answer = a - b
        let choices = generateChoices(correctAnswer: answer, count: difficulty.choiceCount, range: range)
        return MathProblem(operand1: a, operand2: b, operation: .subtraction, correctAnswer: answer, choices: choices)
    }
}

struct MultiplicationEngine: MathEngine {
    let operation = MathOperation.multiplication

    func generateProblem(difficulty: DifficultyLevel) -> MathProblem {
        let a = Int.random(in: 1...10)
        let b: Int
        switch difficulty {
        case .level4:
            b = [2, 5, 10].randomElement()!
        default:
            b = Int.random(in: 1...10)
        }
        let answer = a * b
        let choices = generateChoices(correctAnswer: answer, count: difficulty.choiceCount, range: 0...100)
        return MathProblem(operand1: a, operand2: b, operation: .multiplication, correctAnswer: answer, choices: choices)
    }
}

struct DivisionEngine: MathEngine {
    let operation = MathOperation.division

    func generateProblem(difficulty: DifficultyLevel) -> MathProblem {
        // Generate division by creating a multiplication fact and reversing it
        let answer = Int.random(in: 1...10)
        let divisor = Int.random(in: 1...5)
        let dividend = answer * divisor
        let choices = generateChoices(correctAnswer: answer, count: difficulty.choiceCount, range: 0...20)
        return MathProblem(operand1: dividend, operand2: divisor, operation: .division, correctAnswer: answer, choices: choices)
    }
}

class MathEngineFactory {
    static func engine(for operation: MathOperation) -> MathEngine {
        switch operation {
        case .addition: return AdditionEngine()
        case .subtraction: return SubtractionEngine()
        case .multiplication: return MultiplicationEngine()
        case .division: return DivisionEngine()
        }
    }
}
