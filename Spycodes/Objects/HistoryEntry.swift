import Foundation

class HistoryEntry: NSObject, NSCoding {
    private var word: String
    private var player: Player
    private var team: Team
    
    override init() {
        self.word = "Default"
        self.player = Player()
        self.team = Team.Red
    }
    
    convenience init(word: String, player: Player, team: Team) {
        self.init()
        self.word = word
        self.player = player
        self.team = team
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        if let word = aDecoder.decodeObjectForKey("word") as? String, player = aDecoder.decodeObjectForKey("player") as? Player, team = aDecoder.decodeObjectForKey("team") as? Int {
            self.init(word: word, player: player, team: Team(rawValue: team)!)
        } else {
            self.init()
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.word, forKey: "word")
        aCoder.encodeObject(self.player, forKey: "player")
        aCoder.encodeObject(self.team.rawValue, forKey: "team")
    }
}
