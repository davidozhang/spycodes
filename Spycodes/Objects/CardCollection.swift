import Foundation

class CardCollection: NSObject, NSCoding {
    static var instance = CardCollection()

    fileprivate var keyObject = Key()
    fileprivate let words = SCWordList.getShuffledWords()

    fileprivate var cards = [Card]()
    fileprivate var key = [Team]()
    fileprivate var startingTeam: Team

    // MARK: Constructor/Destructor
    override init() {
        if GameMode.instance.getMode() == .miniGame {
            self.startingTeam = .red
            self.keyObject = Key(startingTeam: self.startingTeam)
            self.key = self.keyObject.getKey()
        } else {
            self.key = self.keyObject.getKey()
            self.startingTeam = self.keyObject.getStartingTeam()
        }
        for i in 0..<SCConstants.constant.cardCount.rawValue {
            self.cards.append(
                Card(
                    word: words[i],
                    selected: false,
                    team: self.key[i]
                )
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
    func encode(with aCoder: NSCoder) {
        aCoder.encode(
            self.cards,
            forKey: SCConstants.coding.cards.rawValue
        )
    }

    required convenience init?(coder aDecoder: NSCoder) {
        if let cards = aDecoder.decodeObject(
            forKey: SCConstants.coding.cards.rawValue
        ) as? [Card] {
            self.init(cards: cards)
        } else {
            self.init()
        }
    }

    // MARK: Public
    func getCards() -> [Card] {
        return self.cards
    }

    func getStartingTeam() -> Team {
        return self.startingTeam
    }

    func getCardsRemainingForTeam(_ team: Team) -> Int {
        return self.cards.filter({
            ($0 as Card).getTeam() == team && !($0 as Card).isSelected()
        }).count
    }

    // Minigame Specific
    func autoEliminateOpponentTeamCard(_ opponentTeam: Team) {
        var opponentRemainingCards = self.cards.filter({
            ($0 as Card).getTeam() == opponentTeam && !($0 as Card).isSelected()
        })
        opponentRemainingCards = opponentRemainingCards.shuffled
        if opponentRemainingCards.count > 0 {
            let card = opponentRemainingCards[0]
            self.eliminateCard(card: card)
        }
    }

    // MARK: Private
    fileprivate func eliminateCard(card: Card) {
        for i in 0..<SCConstants.constant.cardCount.rawValue {
            if self.cards[i].getWord() == card.getWord() {
                self.cards[i].setSelected()

                // TODO: Figure out how to send event without artificial delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    SCViewController.broadcastEvent(
                        .selectCard,
                        optional: [
                            SCConstants.coding.name.rawValue: SCStrings.player.cpu.rawValue,
                            SCConstants.coding.card.rawValue: self.cards[i]
                        ]
                    )
                })

                return
            }
        }
    }
}
