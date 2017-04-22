class Timeline {
    static let instance = Timeline()

    fileprivate var events = [ActionEvent]()

    func getEvents() -> [ActionEvent] {
        return self.events
    }

    func reset() {
        self.events.removeAll()
    }
}
