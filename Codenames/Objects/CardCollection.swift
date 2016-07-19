import Foundation

class CardCollection: NSObject, NSCoding {
    static let instance = CardCollection()
    private let keyObject = Key()
    private let words = CodenamesWordList.getTwentyFiveShuffledWords()
    
    var cards = [Card]()
    var key: [Team]?
    
    override init() {
        self.key = self.keyObject.getKey()
        for i in 0..<25 {
            self.cards.append(Card(word: words[i], selected: false, team: self.key![i]))
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
}
