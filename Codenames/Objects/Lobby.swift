import Foundation

class Lobby {
    static let instance = Lobby()
    var rooms = [Room]()
    
    func addRoomWithName(name: String) {
        let room = Room()
        room.setRoomName(name)
        self.rooms.append(room)
    }
    
    func getRooms() -> [Room] {
        return self.rooms
    }
    
    func getRoomWithName(name: String) -> Room? {
        return self.rooms.filter({($0 as Room).getRoomName() == name})[0]
    }
    
    func hasRoomWithName(name: String) -> Bool {
        return self.getRoomWithName(name) != nil
    }
    
    func removeRoomWithName(name: String) {
        self.rooms = self.rooms.filter({($0 as Room).getRoomName() != name})
    }
    
    func getNumberOfRooms() -> Int {
        return self.rooms.count
    }
}