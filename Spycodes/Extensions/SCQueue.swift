public struct SCQueue<T> {
    fileprivate var queue = [T?]()
    fileprivate var head = 0

    public var isEmpty: Bool {
        return count == 0
    }

    public var count: Int {
        return queue.count - head
    }

    public mutating func enqueue(_ element: T) {
        queue.append(element)
    }

    public mutating func dequeue() -> T? {
        guard let element = queue[head], head < queue.count, !isEmpty else {
            return nil
        }

        queue[head] = nil
        head += 1

        let percentage = Double(head)/Double(queue.count)
        if queue.count > 20 && percentage > 0.25 {
            queue.removeFirst(head)
            head = 0
        }

        return element
    }
    
    public var front: T? {
        if isEmpty {
            return nil
        } else {
            return queue[head]
        }
    }
}
