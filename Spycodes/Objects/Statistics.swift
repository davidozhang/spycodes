import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class Statistics: NSObject, NSCoding {
    static var instance = Statistics()
    fileprivate var bestRecord: Int?        // For minigame
    fileprivate var statistics = [Team.red: 0, Team.blue: 0]        // For regular game
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        if let red = aDecoder.decodeObject(forKey: "red") as? Int, let blue = aDecoder.decodeObject(forKey: "blue") as? Int {
            self.statistics = [Team.red: red, Team.blue: blue]
        }
        if let bestRecord = aDecoder.decodeObject(forKey: "bestRecord") as? Int {
            self.bestRecord = bestRecord
        }
    }
    
    deinit {
        self.statistics.removeAll()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.statistics[Team.red], forKey: "red")
        aCoder.encode(self.statistics[Team.blue], forKey: "blue")
        aCoder.encode(self.bestRecord, forKey: "bestRecord")
    }
    
    func recordWinForTeam(_ winningTeam: Team) {
        self.statistics[winningTeam]! += 1
    }
    
    func getStatistics() -> [Team: Int] {
        return self.statistics
    }
    
    func getBestRecord() -> Int? {
        return self.bestRecord
    }
    
    func setBestRecord(_ record: Int) {
        if self.bestRecord == nil {
            self.bestRecord = record
        }
        else if record > bestRecord {
            self.bestRecord = record
        }
    }
    
    func reset() {
        self.statistics = [Team.red: 0, Team.blue: 0]
        self.bestRecord = nil
    }
}
