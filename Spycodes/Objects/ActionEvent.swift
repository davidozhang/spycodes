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
            aCoder.encode(type, forKey: SCConstants.coding.actionEventType.rawValue)
        }
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        if aDecoder.containsValue(forKey: SCConstants.coding.actionEventType.rawValue) {
            let type = aDecoder.decodeInteger(
                forKey: SCConstants.coding.actionEventType.rawValue
            )

            self.type = EventType(rawValue: type)
        }
    }

    // MARK: Public
    func getType() -> EventType? {
        return self.type
    }
}
