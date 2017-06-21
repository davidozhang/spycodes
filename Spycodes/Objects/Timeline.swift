import Foundation

class Timeline {
    static let instance = Timeline()
    static var observedEvents: Set = [
        Event.EventType.confirm,
        Event.EventType.endRound,
        Event.EventType.selectCard,
    ]

    fileprivate var events = [Event]()
    fileprivate var lastTimestamp: Int?

    fileprivate var hasUnread = false

    func getEvents() -> [Event] {
        return self.events
    }

    func hasUnreadEvents() -> Bool {
        return hasUnread
    }

    func addEventIfNeeded(event: Event) {
        if let timestamp = event.getTimestamp() {
            if let lastTimestamp = self.lastTimestamp,
               timestamp <= lastTimestamp {
                return
            }

            self.lastTimestamp = timestamp

            event.addParameter(
                key: SCConstants.coding.hasRead.rawValue,
                value: false
            )

            // Sorted by reverse chronological order
            self.events.insert(event, at: 0)
            self.hasUnread = true

            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(
                    name: Notification.Name(
                        rawValue: SCConstants.notificationKey.timelineUpdated.rawValue
                    ),
                    object: self,
                    userInfo: nil
                )
            })
        }
    }

    func markAllAsRead() {
        for event in self.events {
            event.setParameter(
                key: SCConstants.coding.hasRead.rawValue,
                value: true
            )
        }

        self.hasUnread = false
    }

    func reset() {
        self.lastTimestamp = nil
        self.events.removeAll()
    }
}
