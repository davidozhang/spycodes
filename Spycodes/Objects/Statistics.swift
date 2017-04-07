import Foundation

class Statistics: NSObject, NSCoding {
    static var instance = Statistics()
    fileprivate var bestRecord: Int?        // For minigame
    fileprivate var statistics = [Team.red: 0, Team.blue: 0]        // For regular game

    // MARK: Constructor/Destructor
    deinit {
        self.statistics.removeAll()
    }

    // MARK: Coder
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.statistics[Team.red], forKey: SCCodingConstants.red)
        aCoder.encode(self.statistics[Team.blue], forKey: SCCodingConstants.blue)
        
        if let bestRecord = self.bestRecord {
            aCoder.encode(bestRecord, forKey: SCCodingConstants.bestRecord)
        }
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()

        let red = aDecoder.decodeObject(
            forKey: SCCodingConstants.red
        ) as? Int ?? aDecoder.decodeInteger(
            forKey: SCCodingConstants.red
        )

        let blue = aDecoder.decodeObject(
            forKey: SCCodingConstants.blue
        ) as? Int ?? aDecoder.decodeInteger(
            forKey: SCCodingConstants.blue
        )

        self.statistics = [Team.red: red, Team.blue: blue]

        if aDecoder.containsValue(forKey: SCCodingConstants.bestRecord) {
            let bestRecord = aDecoder.decodeObject(
                forKey: SCCodingConstants.bestRecord
            ) as? Int ?? aDecoder.decodeInteger(
                forKey: SCCodingConstants.bestRecord
            )

            self.bestRecord = bestRecord
        }
    }

    // MARK: Public
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
        } else if let bestRecord = bestRecord, record > bestRecord {
            self.bestRecord = record
        }
    }

    func reset() {
        self.statistics = [Team.red: 0, Team.blue: 0]
        self.bestRecord = nil
    }
}
