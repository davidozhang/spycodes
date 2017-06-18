enum ActionButtonState: Int {
    case confirm = 0
    case endRound = 1
    case gameOver = 2
    case gameAborted = 3
}

enum ReadyButtonState: Int {
    case notReady = 0
    case ready = 1
}

enum TimerState: Int {
    case stopped = 0
    case willStart = 1
    case started = 2
}
