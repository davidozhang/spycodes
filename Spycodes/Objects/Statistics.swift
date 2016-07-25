import Foundation

class Statistics: NSObject, NSCoding {
    static var instance = Statistics()
    private var statistics = [Team.Red: 0, Team.Blue: 0]
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        if let red = aDecoder.decodeObjectForKey("red") as? Int, blue = aDecoder.decodeObjectForKey("blue") as? Int {
            self.statistics = [Team.Red: red, Team.Blue: blue]
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.statistics[Team.Red], forKey: "red")
        aCoder.encodeObject(self.statistics[Team.Blue], forKey: "blue")
    }
    
    func recordWinForTeam(winningTeam: Team) {
        self.statistics[winningTeam]! += 1
    }
    
    func getStatistics() -> [Team: Int] {
        return self.statistics
    }
}
