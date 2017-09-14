class SCLogger {
    func getIdentifier() -> String? {
        return nil
    }

    static func log(identifier: String?, _ statement: String) {
        if let identifier = identifier {
            print(String(format: "[%@] %@", identifier, statement))
        } else {
            print(statement)
        }

    }

    func log(_ statement: String) {
        SCLogger.log(identifier: self.getIdentifier(), statement)
    }
}
