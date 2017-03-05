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
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        if let currentTeam = aDecoder.decodeObjectForKey("team") as? Int {
            self.currentTeam = Team(rawValue: currentTeam)
        }
        if let clue = aDecoder.decodeObjectForKey("clue") as? String {
            self.clue = clue
        }
        if let numberOfWords = aDecoder.decodeObjectForKey("numberOfWords") as? String {
            self.numberOfWords = numberOfWords
        }
        if let winningTeam = aDecoder.decodeObjectForKey("winningTeam") as? Int {
            self.winningTeam = Team(rawValue: winningTeam)
        }
        
        self.abort = aDecoder.decodeBoolForKey("abort")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        if let team = self.currentTeam?.rawValue {
            aCoder.encodeObject(team, forKey: "team")
        }
        if let clue = self.clue {
            aCoder.encodeObject(clue, forKey: "clue")
        }
        if let numberOfWords = self.numberOfWords {
            aCoder.encodeObject(numberOfWords, forKey: "numberOfWords")
        }
        if let winningTeam = self.winningTeam?.rawValue {
            aCoder.encodeObject(winningTeam, forKey: "winningTeam")
        }
        
        aCoder.encodeBool(self.abort, forKey: "abort")
    }
    
    func setStartingTeam(team: Team) {
        self.currentTeam = team
    }
    
    func isClueSet() -> Bool {
        return self.clue != nil
    }
    
    func isNumberOfWordsSet() -> Bool {
        return self.numberOfWords != nil
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
