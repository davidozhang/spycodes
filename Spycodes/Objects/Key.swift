import Foundation

class Key {
    private var startingTeam: Team?
    private var key = [Team]()
    
    init() {
        if let startingTeam = Team(rawValue: self.randomBinarySingleDigit()) {
            self.startingTeam = startingTeam
            self.key += [Team.Assassin]
            self.key += Array(count: 8, repeatedValue: Team.Red)
            self.key += Array(count: 8, repeatedValue: Team.Blue)
            self.key += [startingTeam]
        }
        
        self.key = self.key.shuffled
    }
    
    init(startingTeam: Team) {
        self.key += [Team.Assassin]
        self.key += Array(count: 8, repeatedValue: Team.Red)
        self.key += Array(count: 8, repeatedValue: Team.Blue)
        self.key += [startingTeam]
        self.key = self.key.shuffled
    }
    
    deinit {
        self.key.removeAll()
    }
    
    func randomBinarySingleDigit() -> Int {
        return arc4random_uniform(2) == 0 ? 1: 0
    }
    
    func getKey() -> [Team] {
        return self.key
    }
    
    func getStartingTeam() -> Team {
        if let startingTeam = self.startingTeam {
            return startingTeam
        } else {
            return Team.Red
        }
    }
}
