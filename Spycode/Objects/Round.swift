import Foundation

class Round: NSObject, NSCoding {
    static let instance = Round()
    static let defaultClueGiverClue = "Enter Clue"
    static let defaultNonTurnClue = "Not Your Turn"
    static let defaultIsTurnClue = "Waiting for Clue..."
    static let defaultNumberOfWords = "∞"
    
    var currentTeam: Team?
    var clue: String?
    var numberOfWords: String?
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        if let team = aDecoder.decodeObjectForKey("team") as? Int {
            self.currentTeam = Team(rawValue: team)
        }
        if let clue = aDecoder.decodeObjectForKey("clue") as? String {
            self.clue = clue
        }
        if let numberOfWords = aDecoder.decodeObjectForKey("numberOfWords") as? String {
            self.numberOfWords = numberOfWords
        }
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
        self.currentTeam = Team(rawValue: endingTeam.rawValue ^ 1)
        self.clue = nil
        self.numberOfWords = nil
    }
}
