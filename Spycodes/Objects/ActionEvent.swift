import Foundation

class ActionEvent: NSObject, NSCoding {
    enum EventType: Int {
        case endRound = 0
        case confirm = 1
    }

    fileprivate var type: EventType?

    // MARK: Constructor/Destructor
    convenience init(type: EventType) {
        self.init()
        self.type = type
    }

    // MARK: Coder
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.type?.rawValue, forKey: SCCodingConstants.actionEventType)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        if let eventType = aDecoder.decodeObject(forKey: SCCodingConstants.actionEventType) as? Int {
            self.type = EventType(rawValue: eventType)
        }
    }

    // MARK: Public
    func getType() -> EventType? {
        return self.type
    }
}
