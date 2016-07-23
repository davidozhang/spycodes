import Foundation

class Lobby {
    static var instance = Lobby()
    
    var rooms = [Room]()
    
    func addRoomWithName(name: String) {
        let room = Room()
        room.name = name
        self.rooms.append(room)
    }
    
    func getRoomWithName(name: String) -> Room? {
        let filtered = self.rooms.filter({($0 as Room).name == name})
        if filtered.count == 1 {
            return filtered[0]
        }
        else {
            return nil
        }
    }
    
    func hasRoomWithName(name: String) -> Bool {
        return self.getRoomWithName(name) != nil
    }
    
    func removeRoomWithName(name: String) {
        self.rooms = self.rooms.filter({($0 as Room).name != name})
    }
}