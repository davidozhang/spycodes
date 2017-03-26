enum ActionButtonState: Int {
    case Confirm = 0
    case EndRound = 1
}

enum LobbyRoomState: Int {
    case Normal = 0
    case JoiningRoom = 1
    case Failed = 2
}

enum TimerState: Int {
    case Stopped = 0
    case WillStart = 1
    case Started = 2
}
