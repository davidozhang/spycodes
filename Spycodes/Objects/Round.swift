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

    // MARK: Coder
    func encodeWithCoder(aCoder: NSCoder) {
        if let team = self.currentTeam?.rawValue {
            aCoder.encodeObject(team, forKey: SCCodingConstants.team)
        }

        if let clue = self.clue {
            aCoder.encodeObject(clue, forKey: SCCodingConstants.clue)
        }

        if let numberOfWords = self.numberOfWords {
            aCoder.encodeObject(numberOfWords, forKey: SCCodingConstants.numberOfWords)
        }

        if let winningTeam = self.winningTeam?.rawValue {
            aCoder.encodeObject(winningTeam, forKey: SCCodingConstants.winningTeam)
        }

        aCoder.encodeBool(self.abort, forKey: SCCodingConstants.abort)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()

        if let currentTeam = aDecoder.decodeObjectForKey(SCCodingConstants.team) as? Int {
            self.currentTeam = Team(rawValue: currentTeam)
        }

        if let clue = aDecoder.decodeObjectForKey(SCCodingConstants.clue) as? String {
            self.clue = clue
        }

        if let numberOfWords = aDecoder.decodeObjectForKey(SCCodingConstants.numberOfWords) as? String {
            self.numberOfWords = numberOfWords
        }

        if let winningTeam = aDecoder.decodeObjectForKey(SCCodingConstants.winningTeam) as? Int {
            self.winningTeam = Team(rawValue: winningTeam)
        }

        self.abort = aDecoder.decodeBoolForKey(SCCodingConstants.abort)
    }

    // MARK: Public
    func setStartingTeam(team: Team) {
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

    func endRound(endingTeam: Team) {
        self.clue = nil
        self.numberOfWords = nil

        if GameMode.instance.mode == GameMode.Mode.MiniGame {
            CardCollection.instance.autoEliminateOpponentTeamCard(Team.Blue)
            NSNotificationCenter.defaultCenter().postNotificationName(SCNotificationKeys.autoEliminateNotificationKey, object: self, userInfo: nil)

            if CardCollection.instance.getCardsRemainingForTeam(Team.Blue) == 0 {
                NSNotificationCenter.defaultCenter().postNotificationName(SCNotificationKeys.minigameGameOverNotificationKey, object: self, userInfo: ["title": "Minigame Game Over", "reason": "Your opponent team won!"])
            }

            return
        }
        self.currentTeam = Team(rawValue: endingTeam.rawValue ^ 1)
    }

    func abortGame() {
        self.abort = true
    }
}
