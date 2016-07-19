import Foundation

class Card: NSObject, NSCoding {
    private var word: String
    private var selected: Bool
    private var team: Team
    
    override init() {
        self.word = "Default"
        self.selected = false
        self.team = Team.Red
    }
    
    convenience init(word: String, selected: Bool, team: Team) {
        self.init()
        self.word = word
        self.selected = selected
        self.team = team
    }
    
    convenience init(word: String, selected: Bool, team: Int) {
        self.init()
        self.word = word
        self.selected = selected
        if let team = Team(rawValue: team) {
            self.team = team
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        if let word = aDecoder.decodeObjectForKey("word") as? String, team = aDecoder.decodeObjectForKey("team") as? Int {
            let selected = aDecoder.decodeBoolForKey("selected")
            self.init(word: word, selected: selected, team: team)
        } else {
            self.init()
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.word, forKey: "word")
        aCoder.encodeBool(self.selected, forKey: "selected")
        aCoder.encodeObject(self.team.rawValue, forKey: "team")
    }
    
    func getWord() -> String {
        return self.word
    }
    
    func isSelected() -> Bool {
        return self.selected
    }
    
    func getTeam() -> Team {
        return self.team
    }
}
