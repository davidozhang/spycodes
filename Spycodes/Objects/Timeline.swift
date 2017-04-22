class Timeline {
    static let instance = Timeline()
    static var observedEvents: Set = [
        Event.EventType.confirm,
        Event.EventType.endRound,
        Event.EventType.selectCard,
    ]

    fileprivate var events = [Event]()
    fileprivate var lastTimestamp: Int?

    func getEvents() -> [Event] {
        return self.events
    }

    func addEventIfNeeded(event: Event) {
        if let timestamp = event.getTimestamp() {
            if let lastTimestamp = self.lastTimestamp, timestamp <= lastTimestamp {
                return
            }

            self.lastTimestamp = timestamp

            // Sorted by reverse chronological order
            self.events.insert(event, at: 0)
        }
    }

    func reset() {
        self.lastTimestamp = nil
        self.events.removeAll()
    }
}
