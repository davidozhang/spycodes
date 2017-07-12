enum ActionButtonState: Int {
    case confirm = 0
    case endRound = 1
    case gameOver = 2
    case gameAborted = 3
    case showAnswer = 4
    case hideAnswer = 5
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

enum PregameModalPageState: Int {
    case main = 0
    case secondary = 1
}

class SCStates {
    static var actionButtonState: ActionButtonState = .endRound
    static var readyButtonState: ReadyButtonState = .notReady
    static var timerState: TimerState = .stopped
    static var pregameModalPageState: PregameModalPageState = .main

    static func reset() {
        SCStates.actionButtonState = .endRound
        SCStates.readyButtonState = .notReady
        SCStates.timerState = .stopped
        SCStates.pregameModalPageState = .main
    }
}
