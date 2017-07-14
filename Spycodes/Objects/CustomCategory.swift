class CustomCategory {
    fileprivate var name: String?
    fileprivate var wordList = [String]()

    func setName(name: String) {
        self.name = name
    }

    func getName() -> String? {
        return self.name
    }
}
