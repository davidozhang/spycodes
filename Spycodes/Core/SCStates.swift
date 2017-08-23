enum StateType: Int {
    case actionButton = 0
    case readyButton = 1
    case timer = 2
    case pregameMenu = 3
    case customCategory = 4
}

enum ActionButtonState: Int {
    case confirm = 0
    case endRound = 1
    case gameOver = 2
    case gameAborted = 3
    case showAnswer = 4
    case hideAnswer = 5
}

enum CustomCategoryState: Int {
    case nonEditing = 0
    case addingNewWord = 1
    case editingExistingWord = 2
    case editingCategoryName = 3
    case editingEmoji = 4
}

enum PregameMenuState: Int {
    case main = 0
    case secondary = 1
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

class SCStates {
    static fileprivate var actionButtonState: ActionButtonState = .endRound
    static fileprivate var readyButtonState: ReadyButtonState = .notReady
    static fileprivate var pregameMenuState: PregameMenuState = .main
    static fileprivate var customCategoryState: CustomCategoryState = .nonEditing
    static fileprivate var timerState: TimerState = .stopped

    static func changeState(to state: ActionButtonState) {
        self.actionButtonState = state
    }

    static func changeState(to state: CustomCategoryState) {
        self.customCategoryState = state
    }

    static func changeState(to state: PregameMenuState) {
        self.pregameMenuState = state
    }

    static func changeState(to state: ReadyButtonState) {
        self.readyButtonState = state
    }

    static func changeState(to state: TimerState) {
        self.timerState = state
    }

    static func getActionButtonState() -> ActionButtonState {
        return self.actionButtonState
    }

    static func getCustomCategoryState() -> CustomCategoryState {
        return self.customCategoryState
    }

    static func getPregameMenuState() -> PregameMenuState {
        return self.pregameMenuState
    }

    static func getReadyButtonState() -> ReadyButtonState {
        return self.readyButtonState
    }

    static func getTimerState() -> TimerState {
        return self.timerState
    }

    static func resetAll() {
        SCStates.resetState(type: .actionButton)
        SCStates.resetState(type: .customCategory)
        SCStates.resetState(type: .pregameMenu)
        SCStates.resetState(type: .readyButton)
        SCStates.resetState(type: .timer)
    }

    static func resetState(type: StateType) {
        switch type {
        case .actionButton:
            SCStates.actionButtonState = .endRound
        case .customCategory:
            SCStates.customCategoryState = .nonEditing
        case .pregameMenu:
            SCStates.pregameMenuState = .main
        case .readyButton:
            SCStates.readyButtonState = .notReady
        case .timer:
            SCStates.timerState = .stopped
        }
    }
}
