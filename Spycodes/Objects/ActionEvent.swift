import Foundation

class ActionEvent: NSObject, NSCoding {
    enum EventType: Int {
        case endRound = 0
        case confirm = 1
        case ready = 2
        case cancel = 3
    }

    fileprivate var type: EventType?
    fileprivate var parameters: [String: String]?

    // MARK: Constructor/Destructor
    convenience init(type: EventType, parameters: [String: String]?) {
        self.init()
        self.type = type
        self.parameters = parameters
    }

    // MARK: Coder
    func encode(with aCoder: NSCoder) {
        if let type = self.type?.rawValue {
            aCoder.encode(type, forKey: SCConstants.coding.actionEventType.rawValue)
        }

        if let parameters = self.parameters {
            aCoder.encode(parameters, forKey: SCConstants.coding.parameters.rawValue)
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

        if aDecoder.containsValue(forKey: SCConstants.coding.parameters.rawValue),
           let parameters = aDecoder.decodeObject(forKey: SCConstants.coding.parameters.rawValue) as? [String: String] {
            self.parameters = parameters
        }
    }

    // MARK: Public
    func getType() -> EventType? {
        return self.type
    }

    func getParameters() -> [String: String]? {
        return self.parameters
    }
}
