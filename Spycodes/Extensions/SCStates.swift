enum ActionButtonState: Int {
    case confirm = 0
    case endRound = 1
}

enum LobbyRoomState: Int {
    case normal = 0
    case joiningRoom = 1
    case failed = 2
}

enum TimerState: Int {
    case stopped = 0
    case willStart = 1
    case started = 2
}
