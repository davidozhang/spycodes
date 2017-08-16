import Foundation

class CustomCategory: NSObject, NSCoding, NSCopying {
    fileprivate var name: String?
    fileprivate var emoji: String?
    fileprivate var wordList = [String]()

    convenience init(name: String?, emoji: String?, wordList: [String]) {
        self.init()

        self.name = name
        self.emoji = emoji
        self.wordList = wordList
    }

    // MARK: Coder
    func encode(with aCoder: NSCoder) {
        if let name = self.name {
            aCoder.encode(
                name,
                forKey: SCConstants.coding.categoryName.rawValue
            )
        }

        if let emoji = self.emoji {
            aCoder.encode(
                emoji,
                forKey: SCConstants.coding.categoryEmoji.rawValue
            )
        }

        aCoder.encode(
            self.wordList,
            forKey: SCConstants.coding.categoryWordList.rawValue
        )
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()

        if aDecoder.containsValue(forKey: SCConstants.coding.categoryName.rawValue) {
            if let name = aDecoder.decodeObject(
                forKey: SCConstants.coding.categoryName.rawValue
            ) as? String {
                self.name = name
            }
        }

        if aDecoder.containsValue(forKey: SCConstants.coding.categoryEmoji.rawValue) {
            if let emoji = aDecoder.decodeObject(
                forKey: SCConstants.coding.categoryEmoji.rawValue
                ) as? String {
                self.emoji = emoji
            }
        }

        if let wordList = aDecoder.decodeObject(
            forKey: SCConstants.coding.categoryWordList.rawValue
            ) as? [String] {
            self.wordList = wordList
        }
    }

    // MARK: Copying
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = CustomCategory(name: self.name, emoji: self.emoji, wordList: self.wordList)
        return copy
    }

    // MARK: Public
    func setName(name: String) {
        self.name = name.uppercasedFirst
    }

    func setEmoji(emoji: String) {
        self.emoji = emoji
    }

    func getName() -> String? {
        return self.name
    }

    func getEmoji() -> String? {
        return self.emoji
    }

    func getWordList() -> [String] {
        return self.wordList
    }

    func getWordCount() -> Int {
        return self.wordList.count
    }

    func wordExists(word: String) -> Bool {
        return wordList.map({
            $0.lowercased()
        }).contains(word.lowercased())
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

extension CustomCategory {
    override var hashValue: Int {
        if let nameHashValue = self.name?.hashValue {
            return nameHashValue
        }

        return 0
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? CustomCategory {
            return self.name == object.name
        }

        return false
    }
}
