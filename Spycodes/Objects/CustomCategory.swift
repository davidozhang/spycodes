class CustomCategory {
    fileprivate var name: String?
    fileprivate var wordList = [String]()

    func setName(name: String) {
        self.name = name
    }

    func getName() -> String? {
        return self.name
    }

    func getWordList() -> [String] {
        return self.wordList
    }

    func addWord(word: String) {
        self.wordList.append(word)
    }

    func removeWordAtIndex(index: Int) {
        guard index < self.wordList.count else {
            return
        }

        self.wordList.remove(at: index)
    }
}
