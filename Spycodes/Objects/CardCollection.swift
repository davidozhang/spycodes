import Foundation

class CardCollection: NSObject, NSCoding {
    static var instance = CardCollection()
    
    private let keyObject = Key()
    private let words = SpycodesWordList.getTwentyFiveShuffledWords()
    
    var cards = [Card]()
    var key = [Team]()
    var startingTeam: Team
    
    override init() {
        self.key = self.keyObject.getKey()
        self.startingTeam = self.keyObject.getStartingTeam()
        for i in 0..<25 {
            self.cards.append(Card(word: words[i], selected: false, team: self.key[i]))
        }
    }
    
    convenience init(cards: [Card]) {
        self.init()
        self.cards = cards
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        if let cards = aDecoder.decodeObjectForKey("cards") as? [Card] {
            self.init(cards: cards)
        } else {
            self.init()
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.cards, forKey: "cards")
    }
    
    func getCards() -> [Card] {
        return self.cards
    }
    
    func getCardsRemainingForTeam(team: Team) -> Int {
        return self.cards.filter({($0 as Card).getTeam() == team && !($0 as Card).isSelected()}).count
    }
    
    func getStartingTeam() -> Team {
        return self.startingTeam
    }
}
