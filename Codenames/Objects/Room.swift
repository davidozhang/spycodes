class Room {
    static let instance = Room()
    
    var name: String?
    var players = [Player]()
    
    func setName(name: String) {
        self.name = name
    }
    
    func getName() -> String? {
        guard let name = self.name else { return nil }
        return name
    }
}