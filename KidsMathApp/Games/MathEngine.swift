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
        generateProblem(maxNumber: difficulty.numberRange.upperBound, choiceCount: difficulty.choiceCount)
    }

    func generateProblem(maxNumber: Int, choiceCount: Int = 3) -> MathProblem {
        // Both operands chosen so their sum stays within maxNumber
        let a = Int.random(in: 0...maxNumber)
        let b = Int.random(in: 0...(maxNumber - a))
        let answer = a + b
        let choices = generateChoices(correctAnswer: answer, count: choiceCount, range: 0...maxNumber)
        return MathProblem(operand1: a, operand2: b, operation: .addition, correctAnswer: answer, choices: choices)
    }
}

struct SubtractionEngine: MathEngine {
    let operation = MathOperation.subtraction

    func generateProblem(difficulty: DifficultyLevel) -> MathProblem {
        generateProblem(maxNumber: difficulty.numberRange.upperBound, choiceCount: difficulty.choiceCount)
    }

    func generateProblem(maxNumber: Int, choiceCount: Int = 3) -> MathProblem {
        // a is within maxNumber, b <= a so result is non-negative
        let a = Int.random(in: 0...maxNumber)
        let b = Int.random(in: 0...a)
        let answer = a - b
        let choices = generateChoices(correctAnswer: answer, count: choiceCount, range: 0...maxNumber)
        return MathProblem(operand1: a, operand2: b, operation: .subtraction, correctAnswer: answer, choices: choices)
    }
}

struct MultiplicationEngine: MathEngine {
    let operation = MathOperation.multiplication

    func generateProblem(difficulty: DifficultyLevel) -> MathProblem {
        // Child-friendly: use small numbers, framed as "groups of things"
        let a: Int
        let b: Int
        switch difficulty {
        case .level1, .level2:
            // Very easy: 1-3 groups of 1-3 items (answers 1-9)
            a = Int.random(in: 1...3)
            b = Int.random(in: 1...3)
        case .level3, .level4:
            // Gentle progression: 1-5 groups of 1-5 items (answers 1-25)
            a = Int.random(in: 1...5)
            b = [2, 3, 5].randomElement()!
        case .level5:
            a = Int.random(in: 1...5)
            b = Int.random(in: 2...5)
        }
        let answer = a * b
        let choices = generateChoices(correctAnswer: answer, count: difficulty.choiceCount, range: 0...max(answer + 5, 10))
        return MathProblem(operand1: a, operand2: b, operation: .multiplication, correctAnswer: answer, choices: choices)
    }
}

struct DivisionEngine: MathEngine {
    let operation = MathOperation.division

    func generateProblem(difficulty: DifficultyLevel) -> MathProblem {
        // Child-friendly: generate from multiplication facts so answers are always whole numbers
        // Framed as "sharing equally": dividend items shared among divisor friends
        let answer: Int
        let divisor: Int
        switch difficulty {
        case .level1, .level2:
            // Very easy: small totals, share among 2 (answers 1-3)
            answer = Int.random(in: 1...3)
            divisor = 2
        case .level3, .level4:
            // Gentle progression: share among 2-3 (answers 1-5)
            answer = Int.random(in: 1...5)
            divisor = Int.random(in: 2...3)
        case .level5:
            answer = Int.random(in: 1...5)
            divisor = Int.random(in: 2...4)
        }
        let dividend = answer * divisor
        let choices = generateChoices(correctAnswer: answer, count: difficulty.choiceCount, range: 0...max(answer + 5, 10))
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
