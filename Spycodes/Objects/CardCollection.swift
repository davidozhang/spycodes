import Foundation

class CardCollection: NSObject, NSCoding {
    static var instance = CardCollection()

    private var keyObject = Key()
    private let words = SCWordList.getShuffledWords()

    var cards = [Card]()
    var key = [Team]()
    var startingTeam: Team

    // MARK: Constructor/Destructor
    override init() {
        if GameMode.instance.mode == GameMode.Mode.MiniGame {
            self.startingTeam = Team.Red
            self.keyObject = Key(startingTeam: self.startingTeam)
            self.key = self.keyObject.getKey()
        } else {
            self.key = self.keyObject.getKey()
            self.startingTeam = self.keyObject.getStartingTeam()
        }
        for i in 0..<SCConstants.cardCount {
            self.cards.append(
                Card(word: words[i], selected: false, team: self.key[i])
            )
        }
    }

    convenience init(cards: [Card]) {
        self.init()
        self.cards = cards
    }

    deinit {
        self.cards.removeAll()
        self.key.removeAll()
    }

    // MARK: Coder
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.cards, forKey: SCCodingConstants.cards)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        if let cards = aDecoder.decodeObjectForKey(SCCodingConstants.cards) as? [Card] {
            self.init(cards: cards)
        } else {
            self.init()
        }
    }

    // MARK: Public
    func getCardsRemainingForTeam(team: Team) -> Int {
        return self.cards.filter({
            ($0 as Card).getTeam() == team && !($0 as Card).isSelected()
        }).count
    }

    // Minigame Specific
    func autoEliminateOpponentTeamCard(opponentTeam: Team) {
        var opponentRemainingCards = self.cards.filter({
            ($0 as Card).getTeam() == opponentTeam && !($0 as Card).isSelected()
        })
        opponentRemainingCards = opponentRemainingCards.shuffled
        if opponentRemainingCards.count > 0 {
            let eliminatedCard = opponentRemainingCards[0]
            for i in 0..<SCConstants.cardCount {
                if self.cards[i].getWord() == eliminatedCard.getWord() {
                    self.cards[i].setSelected()
                    return
                }
            }
        }
    }

    // Convert Bystander card to Team Card (Currently disabled)
    func autoConvertNeutralCardToTeamCard() {
        var neutralRemainingCards = self.cards.filter({
            ($0 as Card).getTeam() == Team.Neutral && !($0 as Card).isSelected()
        })
        neutralRemainingCards = neutralRemainingCards.shuffled
        if neutralRemainingCards.count > 0 {
            let convertedCard = neutralRemainingCards[0]
            for i in 0..<SCConstants.cardCount {
                if self.cards[i].getWord() == convertedCard.getWord() {
                    self.cards[i].setTeam(Player.instance.team)
                    NSNotificationCenter.defaultCenter().postNotificationName(
                        SCNotificationKeys.autoConvertBystanderCardNotificationkey,
                        object: self,
                        userInfo: nil
                    )
                    return
                }
            }
        }
    }
}
