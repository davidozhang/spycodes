import Foundation

class Statistics: NSObject, NSCoding {
    static var instance = Statistics()
    fileprivate var bestRecord: Int?        // For minigame
    fileprivate var statistics: [Team: Int] = [.red: 0, .blue: 0]        // For regular game

    // MARK: Constructor/Destructor
    deinit {
        self.statistics.removeAll()
    }

    // MARK: Coder
    func encode(with aCoder: NSCoder) {
        if let red = self.statistics[.red],
           let blue = self.statistics[.blue] {
            aCoder.encode(red, forKey: SCConstants.coding.red.rawValue)
            aCoder.encode(blue, forKey: SCConstants.coding.blue.rawValue)
        }
        
        if let bestRecord = self.bestRecord {
            aCoder.encode(bestRecord, forKey: SCConstants.coding.bestRecord.rawValue)
        }
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()

        if aDecoder.containsValue(forKey: SCConstants.coding.red.rawValue),
           aDecoder.containsValue(forKey: SCConstants.coding.blue.rawValue) {
            let red = aDecoder.decodeInteger(
                forKey: SCConstants.coding.red.rawValue
            )

            let blue = aDecoder.decodeInteger(
                forKey: SCConstants.coding.blue.rawValue
            )

            self.statistics = [.red: red, .blue: blue]
        }

        if aDecoder.containsValue(forKey: SCConstants.coding.bestRecord.rawValue) {
            let bestRecord = aDecoder.decodeInteger(
                forKey: SCConstants.coding.bestRecord.rawValue
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
        self.statistics = [.red: 0, .blue: 0]
        self.bestRecord = nil
    }
}
