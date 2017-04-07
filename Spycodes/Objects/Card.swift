import Foundation

class Card: NSObject {
    fileprivate var word: String
    fileprivate var selected: Bool
    fileprivate var team: Team

    // MARK: Constructor/Destructor
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

    // MARK: Coder
    func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(self.word, forKey: SCCodingConstants.word)
        aCoder.encode(self.selected, forKey: SCCodingConstants.selected)
        aCoder.encode(self.team.rawValue, forKey: SCCodingConstants.team)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        if let word = aDecoder.decodeObject(forKey: SCCodingConstants.word) as? String {
            let team = aDecoder.decodeInteger(
                forKey: SCCodingConstants.team
            )

            let selected = aDecoder.decodeBool(
                forKey: SCCodingConstants.selected
            )

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

    func setTeam(_ team: Team) {
        self.team = team
    }
}
