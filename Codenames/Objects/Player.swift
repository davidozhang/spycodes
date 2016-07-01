class Player: Equatable {
    static let instance = Player()
    
    var name: String?
    var team: Team?
    var clueGiver: Bool?
    var host: Bool?
    
    func setName(name: String) {
        self.name = name
    }
    
    func setTeam(team: Team) {
        self.team = team
    }
    
    func setClueGiver() {
        self.clueGiver = true
    }
    
    func setHost() {
        self.host = true
    }
    
    func isClueGiver() -> Bool {
        guard let isClueGiver = self.clueGiver else { return false }
        return isClueGiver
    }
    
    func isHost() -> Bool {
        guard let isHost = self.host else { return false }
        return isHost
    }
}

func ==(left: Player, right: Player) -> Bool {
    return left.name == right.name
}