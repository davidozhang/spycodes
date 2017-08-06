import Foundation

class CustomCategory: NSObject, NSCoding, NSCopying {
    fileprivate var name: String?
    fileprivate var wordList = [String]()

    convenience init(name: String?, wordList: [String]) {
        self.init()

        self.name = name
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

        if let wordList = aDecoder.decodeObject(
            forKey: SCConstants.coding.categoryWordList.rawValue
            ) as? [String] {
            self.wordList = wordList
        }
    }

    // MARK: Copying
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = CustomCategory(name: self.name, wordList: self.wordList)
        return copy
    }

    // MARK: Public
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

extension CustomCategory {
    override var hashValue: Int {
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
