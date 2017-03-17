import Foundation

class Card: NSObject {
    private var word: String
    private var selected: Bool
    private var team: Team

    // MARK: Constructor/Destructor
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

    // MARK: Coder
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.word, forKey: "word")
        aCoder.encodeBool(self.selected, forKey: "selected")
        aCoder.encodeObject(self.team.rawValue, forKey: "team")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        if let word = aDecoder.decodeObjectForKey("word") as? String, team = aDecoder.decodeObjectForKey("team") as? Int {
            let selected = aDecoder.decodeBoolForKey("selected")
            self.init(word: word, selected: selected, team: team)
        } else {
            self.init()
        }
    }

    // MARK: Public
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

    func setTeam(team: Team) {
        self.team = team
    }
}
