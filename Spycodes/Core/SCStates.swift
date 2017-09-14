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

    static func changeActionButtonState(to state: ActionButtonState) {
        self.actionButtonState = state
        self.logState(type: .actionButton)
    }

    static func changeCustomCategoryState(to state: CustomCategoryState) {
        self.customCategoryState = state
        self.logState(type: .customCategory)
    }

    static func changePregameMenuState(to state: PregameMenuState) {
        self.pregameMenuState = state
        self.logState(type: .pregameMenu)
    }

    static func changeReadyButtonState(to state: ReadyButtonState) {
        self.readyButtonState = state
        self.logState(type: .readyButton)
    }

    static func changeTimerState(to state: TimerState) {
        self.timerState = state
        self.logState(type: .timer)
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
            SCStates.changeActionButtonState(to: .endRound)
        case .customCategory:
            SCStates.changeCustomCategoryState(to: .nonEditing)
        case .pregameMenu:
            SCStates.changePregameMenuState(to: .main)
        case .readyButton:
            SCStates.changeReadyButtonState(to: .notReady)
        case .timer:
            SCStates.changeTimerState(to: .stopped)
        }
    }
}

// MARK: Logging
extension SCStates {
    static func logState(type: StateType) {
        var output = ""
        switch type {
        case .actionButton:
            output += String(
                format: SCStrings.state.log.rawValue,
                SCStrings.state.actionButton.rawValue,
                SCStates.getActionButtonStateString(state: self.actionButtonState)
            )
        case .customCategory:
            output += String(
                format: SCStrings.state.log.rawValue,
                SCStrings.state.customCategory.rawValue,
                SCStates.getCustomCategoryStateString(state: self.customCategoryState)
            )
        case .pregameMenu:
            output += String(
                format: SCStrings.state.log.rawValue,
                SCStrings.state.pregameMenu.rawValue,
                SCStates.getPregameMenuStateString(state: self.pregameMenuState)
            )
        case .readyButton:
            output += String(
                format: SCStrings.state.log.rawValue,
                SCStrings.state.readyButton.rawValue,
                SCStates.getReadyButtonStateString(state: self.readyButtonState)
            )
        case .timer:
            output += String(
                format: SCStrings.state.log.rawValue,
                SCStrings.state.timer.rawValue,
                SCStates.getTimerStateString(state: self.timerState)
            )
        }

        SCLogger.log(identifier: SCConstants.loggingIdentifier.states.rawValue, output)
    }

    static func getActionButtonStateString(state: ActionButtonState) -> String {
        switch state {
        case .confirm:
            return SCStrings.state.confirm.rawValue
        case .endRound:
            return SCStrings.state.endRound.rawValue
        case .gameAborted:
            return SCStrings.state.gameAborted.rawValue
        case .gameOver:
            return SCStrings.state.gameOver.rawValue
        case .hideAnswer:
            return SCStrings.state.hideAnswer.rawValue
        case .showAnswer:
            return SCStrings.state.showAnswer.rawValue
        }
    }

    static func getCustomCategoryStateString(state: CustomCategoryState) -> String {
        switch state {
        case .addingNewWord:
            return SCStrings.state.addingNewWord.rawValue
        case .editingCategoryName:
            return SCStrings.state.editingCategoryName.rawValue
        case .editingEmoji:
            return SCStrings.state.editingEmoji.rawValue
        case .editingExistingWord:
            return SCStrings.state.editingExistingWord.rawValue
        case .nonEditing:
            return SCStrings.state.nonEditing.rawValue
        }
    }

    static func getPregameMenuStateString(state: PregameMenuState) -> String {
        switch state {
        case .main:
            return SCStrings.state.main.rawValue
        case .secondary:
            return SCStrings.state.secondary.rawValue
        }
    }

    static func getReadyButtonStateString(state: ReadyButtonState) -> String {
        switch state {
        case .notReady:
            return SCStrings.state.notReady.rawValue
        case .ready:
            return SCStrings.state.ready.rawValue
        }
    }

    static func getTimerStateString(state: TimerState) -> String {
        switch state {
        case .stopped:
            return SCStrings.state.stopped.rawValue
        case .willStart:
            return SCStrings.state.willStart.rawValue
        case .started:
            return SCStrings.state.started.rawValue
        }
    }
}
