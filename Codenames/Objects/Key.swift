import Foundation

class Key {
    private var key = [Team]()
    
    init() {
        if let startingTeam = Team(rawValue: self.randomBinarySingleDigit()) {
            self.key += [Team.Assassin]
            self.key += Array(count: 7, repeatedValue: Team.Neutral)
            self.key += Array(count: 8, repeatedValue: Team.Red)
            self.key += Array(count: 8, repeatedValue: Team.Blue)
            self.key += [startingTeam]
        }
        
        self.key = self.key.shuffled
    }
    
    func randomBinarySingleDigit() -> Int {
        return arc4random_uniform(2) == 0 ? 1: 0
    }
    
    func getKey() -> [Team] {
        return self.key
    }
}
