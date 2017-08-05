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

    func getWordCount() -> Int {
        return self.wordList.count
    }

    func wordExists(word: String) -> Bool {
        return wordList.contains(word)
    }

    func addWord(word: String) {
        self.wordList.insert(word, at: 0)
    }

    func editWord(word: String, index: Int) {
        guard index >= 0, index < self.wordList.count else {
            return
        }

        self.wordList[index] = word
    }

    func removeWordAtIndex(index: Int) {
        guard index < self.wordList.count else {
            return
        }

        self.wordList.remove(at: index)
    }
}
