import Foundation

class Event: NSObject, NSCoding {
    enum EventType: Int {
        case endRound = 0
        case confirm = 1
        case ready = 2
        case cancel = 3
        case selectCard = 4
        case gameOver = 5
    }

    fileprivate var uuid: String?
    fileprivate var type: EventType?
    fileprivate var timestamp: Int?
    fileprivate var parameters: [String: Any]?

    // MARK: Constructor/Destructor
    convenience init(type: EventType, parameters: [String: Any]?) {
        self.init()
        self.uuid = UUID().uuidString
        self.timestamp = Int(Date.timeIntervalSinceReferenceDate)
        self.type = type
        self.parameters = parameters
    }

    // MARK: Coder
    func encode(with aCoder: NSCoder) {
        if let uuid = self.uuid {
            aCoder.encode(
                uuid,
                forKey: SCConstants.coding.uuid.rawValue
            )
        }

        if let type = self.type?.rawValue {
            aCoder.encode(
                type,
                forKey: SCConstants.coding.eventType.rawValue
            )
        }

        if let parameters = self.parameters {
            aCoder.encode(
                parameters,
                forKey: SCConstants.coding.parameters.rawValue
            )
        }

        if let timestamp = self.timestamp {
            aCoder.encode(
                timestamp,
                forKey: SCConstants.coding.timestamp.rawValue
            )
        }
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        if aDecoder.containsValue(forKey: SCConstants.coding.uuid.rawValue) {
            if let uuid = aDecoder.decodeObject(
                forKey: SCConstants.coding.uuid.rawValue
            ) as? String {
                self.uuid = uuid
            }
        }

        if aDecoder.containsValue(forKey: SCConstants.coding.eventType.rawValue) {
            let type = aDecoder.decodeInteger(
                forKey: SCConstants.coding.eventType.rawValue
            )

            self.type = EventType(rawValue: type)
        }

        if aDecoder.containsValue(forKey: SCConstants.coding.parameters.rawValue) {
            if let parameters = aDecoder.decodeObject(
                forKey: SCConstants.coding.parameters.rawValue
            ) as? [String: Any] {
                self.parameters = parameters
            }
        }

        self.timestamp = aDecoder.decodeInteger(
            forKey: SCConstants.coding.timestamp.rawValue
        )
    }

    // MARK: Public
    func getType() -> EventType? {
        return self.type
    }

    func getParameters() -> [String: Any]? {
        return self.parameters
    }

    func getTimestamp() -> Int? {
        return self.timestamp
    }

    func addParameter(key: String, value: Any) {
        if self.parameters == nil {
            self.parameters = [String: Any]()
        }

        self.parameters?[key] = value
    }

    func setParameter(key: String, value: Any) {
        guard let _ = self.parameters?[key] else {
            return
        }

        self.parameters?[key] = value
    }
}
