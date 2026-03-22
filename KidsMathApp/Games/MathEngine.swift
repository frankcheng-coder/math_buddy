import Foundation

protocol MathEngine {
    var operation: MathOperation { get }
    func generateProblem(difficulty: DifficultyLevel) -> MathProblem
}

extension MathEngine {
    func generateChoices(correctAnswer: Int, count: Int, range: ClosedRange<Int>) -> [Int] {
        var choices = Set<Int>()
        choices.insert(correctAnswer)

        // Start with close distractors (±5), widen if not enough unique values
        var spread = 5
        while choices.count < count {
            let minChoice = max(0, correctAnswer - spread)
            let maxChoice = correctAnswer + spread
            let wrong = Int.random(in: minChoice...maxChoice)
            if wrong >= 0 && wrong != correctAnswer {
                choices.insert(wrong)
            }
            // Widen range if we're stuck (not enough unique integers in current range)
            if maxChoice - minChoice + 1 <= choices.count {
                spread += 3
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

    func generateProblem(maxNumber: Int, choiceCount: Int = 4) -> MathProblem {
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

    func generateProblem(maxNumber: Int, choiceCount: Int = 4) -> MathProblem {
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
        generateProblem(level: 1)
    }

    /// Level-based generation with gentle scaling.
    /// Lv1: 1-2 × 1-3, Lv2: 1-3 × 1-4, Lv3: 1-4 × 1-5, Lv4+: grows slowly, capped at 9×9.
    func generateProblem(level: Int) -> MathProblem {
        let maxA = min(level + 1, 9)
        let maxB = min(level + 2, 9)
        let a = Int.random(in: 1...maxA)
        let b = Int.random(in: 1...maxB)
        let answer = a * b
        let choices = generateChoices(correctAnswer: answer, count: 4, range: 0...max(answer + 5, 10))
        return MathProblem(operand1: a, operand2: b, operation: .multiplication, correctAnswer: answer, choices: choices)
    }
}

struct DivisionEngine: MathEngine {
    let operation = MathOperation.division

    func generateProblem(difficulty: DifficultyLevel) -> MathProblem {
        generateProblem(level: 1)
    }

    /// Level-based generation derived from multiplication facts — always whole-number answers.
    /// Lv1: answer 1-2, divisor 2. Lv2: answer 1-3, divisor 2-3. Lv3+: grows slowly, capped.
    func generateProblem(level: Int) -> MathProblem {
        let maxAnswer = min(level + 1, 9)
        let maxDivisor = min(level + 1, 6)
        let answer = Int.random(in: 1...maxAnswer)
        let divisor = Int.random(in: 2...max(maxDivisor, 2))
        let dividend = answer * divisor
        let choices = generateChoices(correctAnswer: answer, count: 4, range: 0...max(answer + 5, 10))
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
