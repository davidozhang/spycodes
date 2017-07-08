import Foundation

class Categories: NSObject, NSCoding {
    static var instance = Categories()
    fileprivate var selectedCategories = Set<SCWordBank.Category>()     // Categories selected for curated word list

    // Non-host player synchronization data
    fileprivate var synchronizedCategories = [String: Bool]()         // Mapping from string category to selected boolean
    fileprivate var synchronizedWordCounts = [String: Int]()     // Mapping from string category to word count
    fileprivate var synchronizedEmojis = [String: String]()     // Mapping from string category to emoji

    // MARK: Coder
    override init() {
        super.init()
        self.addAllCategories()
    }

    func encode(with aCoder: NSCoder) {
        for category in SCWordBank.Category.all {
            let string = SCWordBank.getCategoryString(category: category)
            self.synchronizedCategories[string] = self.selectedCategories.contains(category)
            self.synchronizedWordCounts[string] = SCWordBank.getWordCount(category: category)
            self.synchronizedEmojis[string] = SCWordBank.getCategoryEmoji(category: category)
        }

        aCoder.encode(
            self.synchronizedCategories,
            forKey: SCConstants.coding.categories.rawValue
        )
        aCoder.encode(
            self.synchronizedWordCounts,
            forKey: SCConstants.coding.wordCounts.rawValue
        )
        aCoder.encode(
            self.synchronizedEmojis,
            forKey: SCConstants.coding.emojis.rawValue
        )
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()

        if aDecoder.containsValue(forKey: SCConstants.coding.categories.rawValue),
           let categories = aDecoder.decodeObject(forKey: SCConstants.coding.categories.rawValue) as? [String: Bool] {
            self.synchronizedCategories = categories
        }

        if aDecoder.containsValue(forKey: SCConstants.coding.wordCounts.rawValue),
            let wordCounts = aDecoder.decodeObject(forKey: SCConstants.coding.wordCounts.rawValue) as? [String: Int] {
            self.synchronizedWordCounts = wordCounts
        }

        if aDecoder.containsValue(forKey: SCConstants.coding.emojis.rawValue),
            let emojis = aDecoder.decodeObject(forKey: SCConstants.coding.emojis.rawValue) as? [String: String] {
            self.synchronizedEmojis = emojis
        }
    }

    // MARK: Public
    func addCategory(category: SCWordBank.Category) {
        self.selectedCategories.insert(category)
    }

    func addAllCategories() {
        for category in SCWordBank.Category.all {
            self.selectedCategories.insert(category)
        }
    }

    func getSelectedCategories() -> Array<SCWordBank.Category> {
        return Array(self.selectedCategories)
    }

    func getSynchronizedCategories() -> [String] {
        return Array(self.synchronizedCategories.keys.sorted())
    }

    func isSynchronizedCategoryStringSelected(string: String) -> Bool {
        guard let result = self.synchronizedCategories[string] else {
            return false
        }

        return result
    }

    func getSynchronizedEmojiForCategoryString(string: String) -> String? {
        guard let result = self.synchronizedEmojis[string] else {
            return nil
        }

        return result
    }

    func getSynchronizedWordCountForCategoryString(string: String) -> Int {
        guard let result = self.synchronizedWordCounts[string] else {
            return 0
        }

        return result
    }

    func getTotalWords() -> Int {
        var result = 0
        for category in self.selectedCategories {
            result += SCWordBank.getWordCount(category: category)
        }

        return result
    }

    func isCategorySelected(category: SCWordBank.Category) -> Bool {
        return self.selectedCategories.contains(category)
    }

    func removeCategory(category: SCWordBank.Category) {
        self.selectedCategories.remove(category)
    }

    func reset() {
        self.addAllCategories()
        self.synchronizedCategories.removeAll()
        self.synchronizedWordCounts.removeAll()
        self.synchronizedEmojis.removeAll()
    }
}
