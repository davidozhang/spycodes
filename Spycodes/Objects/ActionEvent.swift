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
        if let type = self.type?.rawValue {
            aCoder.encode(type, forKey: SCCodingConstants.actionEventType)
        }
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        if aDecoder.containsValue(forKey: SCCodingConstants.actionEventType) {
            let type = aDecoder.decodeObject(
                forKey: SCCodingConstants.actionEventType
                ) as? Int ?? aDecoder.decodeInteger(
                    forKey: SCCodingConstants.actionEventType
            )

            self.type = EventType(rawValue: type)
        }
    }

    // MARK: Public
    func getType() -> EventType? {
        return self.type
    }
}
