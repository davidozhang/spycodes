import Foundation

class Statistics: NSObject, NSCoding {
    static var instance = Statistics()
    fileprivate var bestRecord: Int?        // For minigame
    fileprivate var score: [Int] = [0, 0]        // For regular game

    // MARK: Constructor/Destructor
    deinit {
        self.score.removeAll()
    }

    // MARK: Coder
    func encode(with aCoder: NSCoder) {
        aCoder.encode(
            self.score,
            forKey: SCConstants.coding.score.rawValue
        )
        
        if let bestRecord = self.bestRecord {
            aCoder.encode(
                bestRecord,
                forKey: SCConstants.coding.bestRecord.rawValue
            )
        }
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()

        if aDecoder.containsValue(forKey: SCConstants.coding.score.rawValue),
            let score = aDecoder.decodeObject(
                forKey: SCConstants.coding.score.rawValue
            ) as? [Int] {
            self.score = score
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
        self.score[winningTeam.rawValue] += 1
        SCMultipeerManager.instance.broadcast(self)
    }

    func getScore() -> [Int] {
        return self.score
    }

    func getBestRecord() -> Int? {
        return self.bestRecord
    }

    func setBestRecord(_ record: Int) {
        if self.bestRecord == nil {
            self.bestRecord = record
        } else if let bestRecord = bestRecord,
                  record > bestRecord {
            self.bestRecord = record
        }

        SCMultipeerManager.instance.broadcast(self)
    }

    func reset() {
        self.score = [0, 0]
        self.bestRecord = nil
    }
}
