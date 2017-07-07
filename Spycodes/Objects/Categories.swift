import Foundation

class Categories: NSObject, NSCoding {
    static var instance = Categories()
    fileprivate var categories = Set<SCWordBank.Category>()     // Categories selected for curated word list

    // MARK: Coder
    override init() {
        super.init()
        self.addAllCategories()
    }

    func encode(with aCoder: NSCoder) {}

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }

    // MARK: Public
    func addCategory(category: SCWordBank.Category) {
        self.categories.insert(category)
    }

    func addAllCategories() {
        for category in SCWordBank.Category.all {
            self.categories.insert(category)
        }
    }

    func getSelectedCategories() -> Array<SCWordBank.Category> {
        return Array(self.categories)
    }

    func getTotalWords() -> Int {
        var result = 0
        for category in self.categories {
            if let wordList = SCWordBank.bank[category] {
                result += wordList.count
            }
        }

        return result
    }

    func isCategorySelected(category: SCWordBank.Category) -> Bool {
        return self.categories.contains(category)
    }

    func removeCategory(category: SCWordBank.Category) {
        self.categories.remove(category)
    }
}
