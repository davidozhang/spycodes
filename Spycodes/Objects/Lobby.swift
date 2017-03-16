import Foundation

class Lobby {
    static var instance = Lobby()

    var rooms = [Room]()

    deinit {
        self.rooms.removeAll()
    }

    func addRoomWithNameAndUUID(name: String, uuid: String) {
        let room = Room()
        room.name = name
        room.setUUID(uuid)
        self.rooms.append(room)
    }

    func getRoomWithUUID(uuid: String) -> Room? {
        let filtered = self.rooms.filter({($0 as Room).getUUID() == uuid})
        if filtered.count == 1 {
            return filtered[0]
        }
        else {
            return nil
        }
    }

    func hasRoomWithUUID(uuid: String) -> Bool {
        return self.getRoomWithUUID(uuid) != nil
    }

    func removeRoomWithUUID(uuid: String) {
        self.rooms = self.rooms.filter({($0 as Room).getUUID() != uuid})
    }

    func reset() {
        self.rooms.removeAll()
    }
}
