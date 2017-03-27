import Foundation

class ActionEvent: NSObject, NSCoding {
    enum EventType: Int {
        case EndRound = 0
    }

    private var type: EventType?

    // MARK: Constructor/Destructor
    convenience init(type: EventType) {
        self.init()
        self.type = type
    }

    // MARK: Coder
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.type?.rawValue, forKey: SCCodingConstants.actionEventType)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        if let eventType = aDecoder.decodeObjectForKey(SCCodingConstants.actionEventType) as? Int {
            self.type = EventType(rawValue: eventType)
        }
    }

    // MARK: Public
    func getType() -> EventType? {
        return self.type
    }
}
