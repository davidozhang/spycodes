import Foundation

class ConsolidatedCategories: NSObject, NSCoding {
    static var instance = ConsolidatedCategories()

    enum CategoryType: Int {
        case defaultCategory = 0
        case customCategory = 1
    }

    fileprivate var allCachedCustomCategories: [CustomCategory]?
    fileprivate var selectedCategories = Set<SCWordBank.Category>()     // Default categories selected for curated word list
    fileprivate var selectedCustomCategories = Set<CustomCategory>()    // Custom categories selected for curated word list

    // Non-host player synchronization data
    fileprivate var synchronizedCategories = [String: Bool]()         // Mapping from string category to selected boolean
    fileprivate var synchronizedCategoryTypes = [String: Int]()     // Mapping from string category to category type
    fileprivate var synchronizedWordCounts = [String: Int]()     // Mapping from string category to word count
    fileprivate var synchronizedEmojis = [String: String]()     // Mapping from string category to emoji

    // MARK: Coder
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
            self.synchronizedCategoryTypes,
            forKey: SCConstants.coding.categoryTypes.rawValue
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

        if aDecoder.containsValue(forKey: SCConstants.coding.categoryTypes.rawValue),
            let categoryTypes = aDecoder.decodeObject(forKey: SCConstants.coding.categoryTypes.rawValue) as? [String: Int] {
            self.synchronizedCategoryTypes = categoryTypes
        }

        if aDecoder.containsValue(forKey: SCConstants.coding.emojis.rawValue),
            let emojis = aDecoder.decodeObject(forKey: SCConstants.coding.emojis.rawValue) as? [String: String] {
            self.synchronizedEmojis = emojis
        }
    }

    // MARK: Public
    func setSelectedCategories(selectedCategories: Set<SCWordBank.Category>) {
        self.selectedCategories = selectedCategories
    }

    func setSelectedCustomCategories(selectedCategories: Set<CustomCategory>) {
        self.selectedCustomCategories = selectedCategories
    }

    func selectCategory(category: SCWordBank.Category, persistSelectionImmediately: Bool) {
        self.selectedCategories.insert(category)

        if persistSelectionImmediately {
            self.persistSelectedCategoriesIfEnabled()
        }
    }

    func unselectCategory(category: SCWordBank.Category, persistSelectionImmediately: Bool) {
        self.selectedCategories.remove(category)

        if persistSelectionImmediately {
            self.persistSelectedCategoriesIfEnabled()
        }
    }

    func selectCustomCategory(category: CustomCategory, persistSelectionImmediately: Bool) {
        self.selectedCustomCategories.insert(category)

        if persistSelectionImmediately {
            self.persistSelectedCategoriesIfEnabled()
        }
    }

    func unselectCustomCategory(category: CustomCategory, persistSelectionImmediately: Bool) {
        self.selectedCustomCategories.remove(category)

        if persistSelectionImmediately {
            self.persistSelectedCategoriesIfEnabled()
        }
    }

    func updateCustomCategory(originalCategory: CustomCategory, updatedCategory: CustomCategory) {
        self.removeCustomCategory(category: originalCategory, persistSelectionImmediately: false)
        self.addCustomCategory(category: updatedCategory, persistSelectionImmediately: false)

        self.unselectCustomCategory(category: originalCategory, persistSelectionImmediately: false)
        self.selectCustomCategory(category: updatedCategory, persistSelectionImmediately: true)
    }

    func addCustomCategory(category: CustomCategory, persistSelectionImmediately: Bool) {
        var allCustomCategories = self.getAllCustomCategories()
        allCustomCategories.append(category)

        SCLocalStorageManager.instance.saveAllCustomCategories(customCategories: allCustomCategories)
        self.selectCustomCategory(category: category, persistSelectionImmediately: persistSelectionImmediately)

        self.allCachedCustomCategories?.append(category)
    }

    func removeCustomCategory(category: CustomCategory, persistSelectionImmediately: Bool) {
        let allCustomCategories = self.getAllCustomCategories()
        let updatedCustomCategories = allCustomCategories.filter({
            $0 != category
        })

        SCLocalStorageManager.instance.saveAllCustomCategories(customCategories: updatedCustomCategories)
        self.unselectCustomCategory(category: category, persistSelectionImmediately: persistSelectionImmediately)

        if let allCachedCustomCategories = self.allCachedCustomCategories {
            self.allCachedCustomCategories = allCachedCustomCategories.filter({
                $0 != category
            })
        }
    }

    func selectAllCategories() {
        for category in SCWordBank.Category.all {
            self.selectCategory(category: category, persistSelectionImmediately: false)
        }

        for category in self.getAllCustomCategories() {
            self.selectCustomCategory(category: category, persistSelectionImmediately: false)
        }

        self.persistSelectedCategoriesIfEnabled()
    }

    func resetCategories() {
        // Retrieve and set to persistent selections if enabled
        if SCLocalStorageManager.instance.isLocalSettingEnabled(.persistentSelection) {
            SCLocalStorageManager.instance.retrieveSelectedConsolidatedCategories()
            return
        }

        self.selectAllCategories()
    }

    func persistSelectedCategoriesIfEnabled() {
        if !SCLocalStorageManager.instance.isLocalSettingEnabled(.persistentSelection) {
            return
        }

        SCLocalStorageManager.instance.saveSelectedCategories(selectedCategories: self.getSelectedCategories())
        SCLocalStorageManager.instance.saveSelectedCustomCategories(selectedCategories: self.getSelectedCustomCategories())
    }

    func allCategoriesSelected() -> Bool {
        return self.selectedCategories.count + self.selectedCustomCategories.count == self.getConsolidatedCategoriesCount()
    }

    // Host-side consolidation of category name, word count and emoji information in a tuple array
    func getConsolidatedCategoriesInfo() -> [(type: CategoryType, name: String, wordCount: Int, emoji: String?)] {
        var result = [(type: CategoryType, name: String, wordCount: Int, emoji: String?)]()

        // Default category names
        for category in SCWordBank.Category.all {
            let name = SCWordBank.getCategoryName(category: category)
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
                    ConsolidatedCategories.split(tuple: (.customCategory, name, wordCount, category.getEmoji()))
                )
            }
        }

        return result.sorted(by: { t1, t2 in
            return t1.name.lowercased() < t2.name.lowercased()
        })
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

    // Integrity check
    func getTotalWordsWithNonPersistedExistingCategory(originalCategory: CustomCategory?, newNonPersistedCategory: CustomCategory?) -> Int {
        if let originalCategory = originalCategory,
           let newNonPersistedCategory = newNonPersistedCategory {
            return self.getTotalWordsWithDeletedExistedCategory(deletedCategory: originalCategory) + newNonPersistedCategory.getWordCount()
        }

        return 0
    }

    func getTotalWordsWithDeletedExistedCategory(deletedCategory: CustomCategory?) -> Int {
        if let deletedCategory = deletedCategory {
            return self.getTotalWords() - deletedCategory.getWordCount()
        }

        return 0
    }

    // Mirrors the mapping function for default categories in SCWordBank
    func getCustomCategoryFromString(string: String?) -> CustomCategory? {
        let filtered = self.getAllCustomCategories().filter({
            $0.getName()?.lowercased() == string?.lowercased()
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
        self.resetSynchronizedInfo()

        // Default categories
        for category in SCWordBank.Category.all {
            let name = SCWordBank.getCategoryName(category: category)
            self.synchronizedCategories[name] = self.selectedCategories.contains(category)
            self.synchronizedWordCounts[name] = SCWordBank.getWordCount(category: category)
            self.synchronizedEmojis[name] = SCWordBank.getCategoryEmoji(category: category)
            self.synchronizedCategoryTypes[name] = CategoryType.defaultCategory.rawValue
        }

        // Custom categories
        for category in self.getAllCustomCategories() {
            if let name = category.getName() {
                self.synchronizedCategories[name] = self.selectedCustomCategories.contains(category)
                self.synchronizedWordCounts[name] = category.getWordCount()
                self.synchronizedEmojis[name] = category.getEmoji()
                self.synchronizedCategoryTypes[name] = CategoryType.customCategory.rawValue
            }
        }
    }

    func resetSynchronizedInfo() {
        self.synchronizedCategories.removeAll()
        self.synchronizedCategoryTypes.removeAll()
        self.synchronizedWordCounts.removeAll()
        self.synchronizedEmojis.removeAll()
    }

    func categoryExists(category: String?) -> Bool {
        // Null category cannot be valid
        guard let category = category else {
            return true
        }

        return SCWordBank.getCategoryFromString(string: category) != nil || self.getCustomCategoryFromString(string: category) != nil
    }

    func isCategorySelected(category: SCWordBank.Category) -> Bool {
        return self.selectedCategories.contains(category)
    }

    func isCustomCategorySelected(category: CustomCategory) -> Bool {
        return self.selectedCustomCategories.contains(category)
    }

    func reset() {
        self.resetCategories()
        self.resetSynchronizedInfo()
    }

    // Non-host methods for synchronized categories
    func getSynchronizedCategories() -> [String] {
        return Array(self.synchronizedCategories.keys.sorted(
            by: { s1, s2 in
                s1.lowercased() < s2.lowercased()
            }
        ))
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

    func getSynchronizedCategoryTypeForCategoryString(string: String) -> CategoryType? {
        guard let result = self.synchronizedCategoryTypes[string] else {
            return nil
        }

        return CategoryType(rawValue: result)
    }

    func getSynchronizedWordCountForCategoryString(string: String) -> Int {
        guard let result = self.synchronizedWordCounts[string] else {
            return 0
        }

        return result
    }

    // MARK: Private
    fileprivate func getAllCustomCategories() -> [CustomCategory] {
        if let allCachedCustomCategories = self.allCachedCustomCategories {
            return allCachedCustomCategories
        }

        let retrievedCustomCategories = SCLocalStorageManager.instance.retrieveAllCustomCategories()
        self.allCachedCustomCategories = retrievedCustomCategories
        return retrievedCustomCategories
    }

    fileprivate static func split(tuple: (CategoryType, String, Int, String?)) -> (type: CategoryType, name: String, wordCount: Int, emoji: String?) {
        return (tuple.0, tuple.1, tuple.2, tuple.3)
    }
}
