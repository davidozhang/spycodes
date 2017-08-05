import Foundation

class ConsolidatedCategories: NSObject, NSCoding {
    static var instance = ConsolidatedCategories()

    enum CategoryType: Int {
        case defaultCategory = 0
        case customCategory = 1
    }

    fileprivate var selectedCategories = Set<SCWordBank.Category>()     // Default categories selected for curated word list
    fileprivate var selectedCustomCategories = Set<CustomCategory>()    // Custom categories selected for curated word list

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
        self.generateSynchronizedCategories()

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

    func addCustomCategory(category: CustomCategory) {
        // Save category to local storage
        self.selectedCustomCategories.insert(category)
    }

    func addAllCategories() {
        for category in SCWordBank.Category.all {
            self.selectedCategories.insert(category)
        }

        // TODO: Add all custom categories loaded from local storage
    }

    // Host-side consolidation of category name, word count and emoji information in a tuple array
    func getConsolidatedCategoryInfo() -> [(type: CategoryType, name: String, wordCount: Int, emoji: String?)] {
        var result = [(CategoryType, String, Int, String?)]()

        // Default category names
        for category in SCWordBank.Category.all {
            let name = SCWordBank.getCategoryString(category: category)
            let wordCount = SCWordBank.getWordCount(category: category)
            let emoji = SCWordBank.getCategoryEmoji(category: category)

            result.append(
                ConsolidatedCategories.split(tuple: (.defaultCategory, name, wordCount, emoji))
            )
        }

        // Custom category names
        for category in ConsolidatedCategories.instance.getAllCustomCategories() {
            if let name = category.getName() {
                let wordCount = category.getWordCount()

                result.append(
                    ConsolidatedCategories.split(tuple: (.customCategory, name, wordCount, nil))
                )
            }
        }

        return result
    }

    func getConsolidatedCategoriesCount() -> Int {
        return SCWordBank.Category.count + self.getAllCustomCategories().count
    }

    func getTotalWords() -> Int {
        var result = 0
        for category in self.selectedCategories {
            result += SCWordBank.getWordCount(category: category)
        }

        for category in self.selectedCustomCategories {
            result += category.getWordCount()
        }

        return result
    }

    // Mirrors the mapping function for default categories in SCWordBank
    func getCustomCategoryFromString(string: String?) -> CustomCategory? {
        let filtered = self.getAllCustomCategories().filter({
            $0.getName() == string
        })

        if filtered.count == 1 {
            return filtered[0]
        }

        return nil
    }

    func getSelectedCategories() -> Array<SCWordBank.Category> {
        return Array(self.selectedCategories)
    }

    func getSelectedCustomCategories() -> Array<CustomCategory> {
        return Array(self.selectedCustomCategories)
    }

    func generateSynchronizedCategories() {
        // Default categories
        for category in SCWordBank.Category.all {
            let string = SCWordBank.getCategoryString(category: category)
            self.synchronizedCategories[string] = self.selectedCategories.contains(category)
            self.synchronizedWordCounts[string] = SCWordBank.getWordCount(category: category)
            self.synchronizedEmojis[string] = SCWordBank.getCategoryEmoji(category: category)
        }

        // Custom categories
        for category in self.getAllCustomCategories() {
            if let name = category.getName() {
                self.synchronizedCategories[name] = self.selectedCustomCategories.contains(category)
                self.synchronizedWordCounts[name] = category.getWordCount()
            }
        }
    }

    func isCategorySelected(category: SCWordBank.Category) -> Bool {
        return self.selectedCategories.contains(category)
    }

    func isCustomCategorySelected(category: CustomCategory) -> Bool {
        return self.selectedCustomCategories.contains(category)
    }

    func removeCategory(category: SCWordBank.Category) {
        self.selectedCategories.remove(category)
    }

    func removeCustomCategory(category: CustomCategory) {
        self.selectedCustomCategories.remove(category)
    }

    func reset() {
        self.addAllCategories()
        self.synchronizedCategories.removeAll()
        self.synchronizedWordCounts.removeAll()
        self.synchronizedEmojis.removeAll()
    }

    // Non-host methods for synchronized categories
    func getSynchronizedCategories() -> [String] {
        return Array(self.synchronizedCategories.keys.sorted())
    }

    func getSynchronizedCategoriesCount() -> Int {
        return self.synchronizedCategories.count
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

    // MARK: Private
    fileprivate func getAllCustomCategories() -> Array<CustomCategory> {
        // TODO: Retrieve all custom categories from local storage
        return self.getSelectedCustomCategories()
    }

    fileprivate static func split(tuple: (CategoryType, String, Int, String?)) -> (type: CategoryType, name: String, wordCount: Int, emoji: String?) {
        return (tuple.0, tuple.1, tuple.2, tuple.3)
    }
}
