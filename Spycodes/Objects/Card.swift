import Foundation

class Card: NSObject, NSCoding {
    fileprivate var word: String
    fileprivate var selected: Bool
    fileprivate var team: Team
    
    override init() {
        self.word = "Default"
        self.selected = false
        self.team = Team.red
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
        if let word = aDecoder.decodeObject(forKey: "word") as? String, let team = aDecoder.decodeObject(forKey: "team") as? Int {
            let selected = aDecoder.decodeBool(forKey: "selected")
            self.init(word: word, selected: selected, team: team)
        } else {
            self.init()
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.word, forKey: "word")
        aCoder.encode(self.selected, forKey: "selected")
        aCoder.encode(self.team.rawValue, forKey: "team")
    }
    
    func getWord() -> String {
        return self.word
    }
    
    func setSelected() {
        self.selected = true
    }
    
    func isSelected() -> Bool {
        return self.selected
    }
    
    func getTeam() -> Team {
        return self.team
    }
    
    func setTeam(_ team: Team) {
        self.team = team
    }
}
