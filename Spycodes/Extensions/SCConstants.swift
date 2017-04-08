class SCConstants {
    enum coding: String {
        case abort = "abort"
        case accessCode = "accessCode"
        case actionEventType = "actionEventType"
        case bestRecord = "bestRecord"
        case blue = "blue"
        case cards = "cards"
        case clue = "clue"
        case cluegiver = "cluegiver"
        case connectedPeers = "connectedPeers"
        case enabled = "enabled"
        case gameEnded = "gameEnded"
        case host = "host"
        case mode = "mode"
        case name = "name"
        case numberOfWords = "numberOfWords"
        case players = "players"
        case red = "red"
        case selected = "selected"
        case team = "team"
        case uuid = "uuid"
        case winningTeam = "winningTeam"
        case word = "word"
    }

    enum constant: Int {
        case accessCodeLength = 4
        case cardCount = 22
        case roomMaxSize = 8
    }

    enum discoveryInfo: String {
        case accessCode = "access-code"
    }

    enum identifier: String {
        case accessCode = "access-code"
        case disclosureViewCell = "disclosure-view-cell"
        case gameRoom = "game-room"
        case gameRoomViewCell = "game-room-view-cell"
        case helpView = "help-view"
        case mainMenu = "main-menu"
        case minigameToggleViewCell = "minigame-toggle-view-cell"
        case nightModeToggleViewCell = "night-mode-toggle-view-cell"
        case playerName = "player-name"
        case pregameModal = "pregame-modal"
        case pregameRoom = "pregame-room"
        case pregameRoomViewCell = "pregame-room-view-cell"
        case sectionHeaderCell = "section-header-view-cell"
        case settings = "settings"
        case timerToggleViewCell = "timer-toggle-view-cell"
        case updateApp = "update-app"
        case versionViewCell = "version-view-cell"
    }

    enum notificationKey: String {
        case autoEliminate = "autoEliminate"
        case minigameGameOver = "minigameGameOver"
    }

    enum url: String {
        case appStore = "itms-apps://itunes.apple.com/app/id1141711201"
        case appStoreWeb = "https://itunes.apple.com/app/spycodes/id1141711201?mt=8"
        case github = "https://github.com/davidozhang/spycodes"
        case icons8 = "https://icons8.com/"
        case support = "https://www.spycodes.net/support/"
        case version = "https://itunes.apple.com/lookup?bundleId=com.davidzhang.Spycodes"
        case website = "https://www.spycodes.net/"
    }

    enum userDefaults: String {
        case nightMode = "nightMode"
    }
}
