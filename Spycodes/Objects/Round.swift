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
            aCoder.encode(team, forKey: SCCodingConstants.team)
        }

        if let clue = self.clue {
            aCoder.encode(clue, forKey: SCCodingConstants.clue)
        }

        if let numberOfWords = self.numberOfWords {
            aCoder.encode(numberOfWords, forKey: SCCodingConstants.numberOfWords)
        }

        if let winningTeam = self.winningTeam?.rawValue {
            aCoder.encode(winningTeam, forKey: SCCodingConstants.winningTeam)
        }

        aCoder.encode(self.abort, forKey: SCCodingConstants.abort)
        aCoder.encode(self.gameEnded, forKey: SCCodingConstants.gameEnded)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()

        if aDecoder.containsValue(forKey: SCCodingConstants.team) {
            let currentTeam = aDecoder.decodeInteger(
                forKey: SCCodingConstants.team
            )

            self.currentTeam = Team(rawValue: currentTeam)
        }

        if aDecoder.containsValue(forKey: SCCodingConstants.clue),
           let clue = aDecoder.decodeObject(forKey: SCCodingConstants.clue) as? String {
            self.clue = clue
        }

        if aDecoder.containsValue(forKey: SCCodingConstants.numberOfWords),
           let numberOfWords = aDecoder.decodeObject(forKey: SCCodingConstants.numberOfWords) as? String {
            self.numberOfWords = numberOfWords
        }

        if aDecoder.containsValue(forKey: SCCodingConstants.winningTeam) {
            let winningTeam = aDecoder.decodeInteger(
                forKey: SCCodingConstants.winningTeam
            )

            self.winningTeam = Team(rawValue: winningTeam)
        }


        self.abort = aDecoder.decodeBool(
            forKey: SCCodingConstants.abort
        )

        self.gameEnded = aDecoder.decodeBool(
            forKey: SCCodingConstants.gameEnded
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

        if GameMode.instance.mode == GameMode.Mode.miniGame {
            CardCollection.instance.autoEliminateOpponentTeamCard(Team.blue)
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: SCNotificationKeys.autoEliminateNotificationKey),
                object: self,
                userInfo: nil
            )

            if CardCollection.instance.getCardsRemainingForTeam(Team.blue) == 0 {
                DispatchQueue.main.async(execute: {
                    NotificationCenter.default.post(
                        name: Notification.Name(rawValue: SCNotificationKeys.minigameGameOverNotificationKey),
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
