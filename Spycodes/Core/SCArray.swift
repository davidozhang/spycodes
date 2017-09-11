import UIKit

extension Array {
    var shuffled: Array {
        var elements = self
        return elements.shuffle()
    }

    fileprivate mutating func shuffle() -> Array {
        indices.dropLast().forEach {
            guard case let index = Int(arc4random_uniform(UInt32(count - $0))) + $0,
                       index != $0 else {
                return
            }

            swap(&self[$0], &self[index])
        }

        return self
    }

    // Picks 'n' random elements (partial Fisher-Yates shuffle approach)
    subscript(choose n: Int) -> [Element] {
        var copy = self
        for i in stride(from: count - 1, to: count - n - 1, by: -1) {
            let j = Int(arc4random_uniform(UInt32(i + 1)))
            if j != i {
                swap(&copy[i], &copy[j])
            }
        }
        return Array(copy.suffix(n))
    }

    func choose(_ n: Int) -> Array {
        return Array(shuffled.prefix(n))
    }
}
