import Foundation

class Statistics: NSObject, NSCoding {
    static var instance = Statistics()
    private var bestRecord: Int?        // For minigame
    private var statistics = [Team.Red: 0, Team.Blue: 0]        // For regular game
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        if let red = aDecoder.decodeObjectForKey("red") as? Int, blue = aDecoder.decodeObjectForKey("blue") as? Int {
            self.statistics = [Team.Red: red, Team.Blue: blue]
        }
        if let bestRecord = aDecoder.decodeObjectForKey("bestRecord") as? Int {
            self.bestRecord = bestRecord
        }
    }
    
    deinit {
        self.statistics.removeAll()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.statistics[Team.Red], forKey: "red")
        aCoder.encodeObject(self.statistics[Team.Blue], forKey: "blue")
        aCoder.encodeObject(self.bestRecord, forKey: "bestRecord")
    }
    
    func recordWinForTeam(winningTeam: Team) {
        self.statistics[winningTeam]! += 1
    }
    
    func getStatistics() -> [Team: Int] {
        return self.statistics
    }
    
    func getBestRecord() -> Int? {
        return self.bestRecord
    }
    
    func setBestRecord(record: Int) {
        if self.bestRecord == nil {
            self.bestRecord = record
        }
        else if record > bestRecord {
            self.bestRecord = record
        }
    }
    
    func reset() {
        self.statistics = [Team.Red: 0, Team.Blue: 0]
        self.bestRecord = nil
    }
}
