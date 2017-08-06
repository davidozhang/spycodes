class CustomCategory {
    fileprivate var name: String?
    fileprivate var wordList = [String]()

    func setName(name: String) {
        self.name = name.uppercasedFirst
    }

    func getName() -> String? {
        return self.name
    }

    func getWordList() -> [String] {
        return self.wordList
    }

    func getWordCount() -> Int {
        return self.wordList.count
    }

    func wordExists(word: String) -> Bool {
        return wordList.contains(word.uppercasedFirst)
    }

    func addWord(word: String) {
        self.wordList.insert(word.uppercasedFirst, at: 0)
    }

    func editWord(word: String, index: Int) {
        guard index >= 0, index < self.wordList.count else {
            return
        }

        self.wordList[index] = word.uppercasedFirst
    }

    func removeWordAtIndex(index: Int) {
        guard index < self.wordList.count else {
            return
        }

        self.wordList.remove(at: index)
    }
}

extension CustomCategory: Hashable {
    var hashValue: Int {
        if let nameHashValue = self.name?.hashValue {
            return nameHashValue
        }

        return 0
    }

    static func == (left: CustomCategory, right: CustomCategory) -> Bool {
        return left.name == right.name
    }

    static func != (left: CustomCategory, right: CustomCategory) -> Bool {
        return left.name != right.name
    }
}
