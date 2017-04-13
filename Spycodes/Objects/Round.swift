import Foundation

class Round: NSObject, NSCoding {
    static var instance = Round()

    fileprivate var currentTeam: Team?
    fileprivate var clue: String?
    fileprivate var numberOfWords: String?
    fileprivate var winningTeam: Team?
    fileprivate var abort = false
    fileprivate var gameEnded = false

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
    func getCurrentTeam() -> Team? {
        return self.currentTeam
    }

    func getClue() -> String? {
        return self.clue
    }

    func getNumberOfWords() -> String? {
        return self.numberOfWords
    }

    func isAborted() -> Bool {
        return self.abort
    }

    func getWinningTeam() -> Team? {
        return self.winningTeam
    }

    func hasGameEnded() -> Bool {
        return self.gameEnded
    }

    func setCurrentTeam(_ team: Team) {
        self.currentTeam = team
        SCMultipeerManager.instance.broadcast(self)
    }

    func setClue(_ clue: String?) {
        self.clue = clue
        SCMultipeerManager.instance.broadcast(self)
    }

    func setNumberOfWords(_ numberOfWords: String?) {
        self.numberOfWords = numberOfWords
        SCMultipeerManager.instance.broadcast(self)
    }

    func setWinningTeam(_ winningTeam: Team?) {
        self.winningTeam = winningTeam
        SCMultipeerManager.instance.broadcast(self)
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
                        userInfo: nil
                    )
                })
            }
        } else {
            self.currentTeam = Team(rawValue: endingTeam.rawValue ^ 1)
        }

        SCMultipeerManager.instance.broadcast(self)
    }

    func abortGame() {
        self.abort = true
        SCMultipeerManager.instance.broadcast(self)
    }

    func endGame() {
        self.gameEnded = true
    }
}
