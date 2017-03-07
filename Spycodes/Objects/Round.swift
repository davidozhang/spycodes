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
        if let currentTeam = aDecoder.decodeObject(forKey: "team") as? Int {
            self.currentTeam = Team(rawValue: currentTeam)
        }
        if let clue = aDecoder.decodeObject(forKey: "clue") as? String {
            self.clue = clue
        }
        if let numberOfWords = aDecoder.decodeObject(forKey: "numberOfWords") as? String {
            self.numberOfWords = numberOfWords
        }
        if let winningTeam = aDecoder.decodeObject(forKey: "winningTeam") as? Int {
            self.winningTeam = Team(rawValue: winningTeam)
        }
        
        self.abort = aDecoder.decodeBool(forKey: "abort")
    }
    
    func encode(with aCoder: NSCoder) {
        if let team = self.currentTeam?.rawValue {
            aCoder.encode(team, forKey: "team")
        }
        if let clue = self.clue {
            aCoder.encode(clue, forKey: "clue")
        }
        if let numberOfWords = self.numberOfWords {
            aCoder.encode(numberOfWords, forKey: "numberOfWords")
        }
        if let winningTeam = self.winningTeam?.rawValue {
            aCoder.encode(winningTeam, forKey: "winningTeam")
        }
        
        aCoder.encode(self.abort, forKey: "abort")
    }
    
    func setStartingTeam(_ team: Team) {
        self.currentTeam = team
    }
    
    func isClueSet() -> Bool {
        return self.clue != nil
    }
    
    func isNumberOfWordsSet() -> Bool {
        return self.numberOfWords != nil
    }
    
    func endRound(_ endingTeam: Team) {
        self.clue = nil
        self.numberOfWords = nil
        
        if GameMode.instance.mode == GameMode.Mode.miniGame {
            CardCollection.instance.autoEliminateOpponentTeamCard(Team.blue)
            NotificationCenter.default.post(name: Notification.Name(rawValue: SCNotificationKeys.autoEliminateNotificationKey), object: self, userInfo: nil)
            
            if CardCollection.instance.getCardsRemainingForTeam(Team.blue) == 0 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: SCNotificationKeys.minigameGameOverNotificationKey), object: self, userInfo: ["title": "Minigame Game Over", "reason": "Your opponent team won!"])
            }
            
            return
        }
        self.currentTeam = Team(rawValue: endingTeam.rawValue ^ 1)
    }
    
    func abortGame() {
        self.abort = true
    }
}
