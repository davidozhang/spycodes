import Foundation

class History: NSObject, NSCoding {
    static var instance = History()
    private var historyEntries = [HistoryEntry]()
    
    convenience init(entries: [HistoryEntry]) {
        self.init()
        self.historyEntries = entries
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        if let entries = aDecoder.decodeObjectForKey("historyEntries") as? [HistoryEntry] {
            self.init(entries: entries)
        } else {
            self.init()
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.historyEntries, forKey: "historyEntries")
    }
    
    func addEntry(entry: HistoryEntry) {
        self.historyEntries.append(entry)
    }
    
    func getEntries() -> [HistoryEntry] {
        return self.historyEntries
    }
    
    deinit {
        self.historyEntries.removeAll()
    }
    
    func reset() {
        self.historyEntries.removeAll()
    }
}
