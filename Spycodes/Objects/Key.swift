import Foundation

class Key {
    fileprivate var startingTeam: Team?
    fileprivate var key = [Team]()

    // MARK: Constructor/Destructor
    init() {
        if let startingTeam = Team(rawValue: self.randomBinarySingleDigit()) {
            self.startingTeam = startingTeam
            self.key += [Team.assassin]
            self.key += Array(repeating: Team.neutral, count: 6)
            self.key += Array(repeating: Team.red, count: 7)
            self.key += Array(repeating: Team.blue, count: 7)
            self.key += [startingTeam]
        }

        self.key = self.key.shuffled
    }

    init(startingTeam: Team) {
        self.key += [Team.assassin]
        self.key += Array(repeating: Team.neutral, count: 6)
        self.key += Array(repeating: Team.red, count: 7)
        self.key += Array(repeating: Team.blue, count: 7)
        self.key += [startingTeam]
        self.key = self.key.shuffled
    }

    deinit {
        self.key.removeAll()
    }

    // MARK: Public
    func getKey() -> [Team] {
        return self.key
    }

    func getStartingTeam() -> Team {
        if let startingTeam = self.startingTeam {
            return startingTeam
        } else {
            return Team.red
        }
    }

    // MARK: Private
    fileprivate func randomBinarySingleDigit() -> Int {
        return arc4random_uniform(2) == 0 ? 1 : 0
    }
}
