import Foundation

class Lobby {
    static let instance = Lobby()
    var rooms = [Room]() {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(CodenamesNotificationKeys.roomsUpdated, object: self)
        }
    }
    
    func addRoomWithName(name: String) {
        let room = Room()
        room.setName(name)
        self.rooms.append(room)
    }
    
    func getRooms() -> [Room] {
        return self.rooms
    }
    
    func getRoomWithName(name: String) -> Room? {
        for i in 0 ..< rooms.count {
            if rooms[i].getName() == name {
                return rooms[i]
            }
        }
        
        return nil
    }
    
    func hasRoomWithName(name: String) -> Bool {
        for i in 0 ..< rooms.count {
            if rooms[i].getName() == name {
                return true
            }
        }
        
        return false
    }
    
    func removeRoomWithName(name: String) {
        for i in 0 ..< rooms.count {
            if rooms[i].getName() == name {
                rooms.removeAtIndex(i)
            }
        }
    }
}