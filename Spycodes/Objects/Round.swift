import Foundation

class Round: NSObject, NSCoding {
    static var instance = Round()

    static let defaultClueGiverClue = "Enter Clue"
    static let defaultNonTurnClue = "Not Your Turn"
    static let defaultIsTurnClue = "Waiting for Clue"
    static let defaultNumberOfWords = "#"
    static let defaultLoseString = "Your team lost!"
    static let defaultWinString = "Your team won!"

    var currentTeam: Team?
    var clue: String?
    var numberOfWords: String?
    var winningTeam: Team?
    var abort = false
    var gameEnded = false

    // MARK: Coder
    func encode(with aCoder: NSCoder) {
        if let team = self.currentTeam?.rawValue {
            aCoder.encode(team, forKey: SCConstants.coding.team.rawValue)
        }

        if let clue = self.clue {
            aCoder.encode(clue, forKey: SCConstants.coding.clue.rawValue)
        }

        if let numberOfWords = self.numberOfWords {
            aCoder.encode(numberOfWords, forKey: SCConstants.coding.numberOfWords.rawValue)
        }

        if let winningTeam = self.winningTeam?.rawValue {
            aCoder.encode(winningTeam, forKey: SCConstants.coding.winningTeam.rawValue)
        }

        aCoder.encode(self.abort, forKey: SCConstants.coding.abort.rawValue)
        aCoder.encode(self.gameEnded, forKey: SCConstants.coding.gameEnded.rawValue)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()

        if aDecoder.containsValue(forKey: SCConstants.coding.team.rawValue) {
            let currentTeam = aDecoder.decodeInteger(
                forKey: SCConstants.coding.team.rawValue
            )

            self.currentTeam = Team(rawValue: currentTeam)
        }

        if aDecoder.containsValue(forKey: SCConstants.coding.clue.rawValue),
           let clue = aDecoder.decodeObject(forKey: SCConstants.coding.clue.rawValue) as? String {
            self.clue = clue
        }

        if aDecoder.containsValue(forKey: SCConstants.coding.numberOfWords.rawValue),
           let numberOfWords = aDecoder.decodeObject(forKey: SCConstants.coding.numberOfWords.rawValue) as? String {
            self.numberOfWords = numberOfWords
        }

        if aDecoder.containsValue(forKey: SCConstants.coding.winningTeam.rawValue) {
            let winningTeam = aDecoder.decodeInteger(
                forKey: SCConstants.coding.winningTeam.rawValue
            )

            self.winningTeam = Team(rawValue: winningTeam)
        }


        self.abort = aDecoder.decodeBool(
            forKey: SCConstants.coding.abort.rawValue
        )

        self.gameEnded = aDecoder.decodeBool(
            forKey: SCConstants.coding.gameEnded.rawValue
        )
    }

    // MARK: Public
    func setStartingTeam(_ team: Team) {
        self.currentTeam = team
    }

    func isClueSet() -> Bool {
        return self.clue != nil
    }

    func isNumberOfWordsSet() -> Bool {
        return self.numberOfWords != nil
    }

    func bothFieldsSet() -> Bool {
        return self.isClueSet() && self.isNumberOfWordsSet()
    }

    func endRound(_ endingTeam: Team) {
        self.clue = nil
        self.numberOfWords = nil

        if GameMode.instance.getMode() == .miniGame {
            CardCollection.instance.autoEliminateOpponentTeamCard(.blue)
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: SCConstants.notificationKey.autoEliminate.rawValue),
                object: self,
                userInfo: nil
            )

            if CardCollection.instance.getCardsRemainingForTeam(.blue) == 0 {
                DispatchQueue.main.async(execute: {
                    NotificationCenter.default.post(
                        name: Notification.Name(rawValue: SCConstants.notificationKey.minigameGameOver.rawValue),
                        object: self,
                        userInfo: [
                            "title": "Minigame Game Over",
                            "reason": "Your opponent team won!"
                        ]
                    )
                })
            }

            return
        }
        self.currentTeam = Team(rawValue: endingTeam.rawValue ^ 1)
    }

    func abortGame() {
        self.abort = true
    }

    func endGame() {
        self.gameEnded = true
    }
}
