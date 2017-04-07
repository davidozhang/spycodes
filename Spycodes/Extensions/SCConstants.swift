class SCConstants {
    enum constant: Int {
        case cardCount = 22
        case accessCodeLength = 4
        case roomMaxSize = 8
    }

    enum coding: String {
        case abort = "abort"
        case bestRecord = "bestRecord"
        case blue = "blue"
        case cards = "cards"
        case clue = "clue"
        case clueGiver = "clueGiver"
        case connectedPeers = "connectedPeers"
        case host = "host"
        case mode = "mode"
        case name = "name"
        case numberOfWords = "numberOfWords"
        case players = "players"
        case red = "red"
        case selected = "selected"
        case team = "team"
        case winningTeam = "winningTeam"
        case word = "word"
        case uuid = "uuid"
        case accessCode = "accessCode"
        case actionEventType = "actionEventType"
        case gameEnded = "gameEnded"
        case timerEnabled = "timerEnabled"
    }

    enum identifier: String {
        case disclosureViewCell = "disclosure-view-cell"
        case gameRoomViewCell = "game-room-view-cell"
        case minigameToggleViewCell = "minigame-toggle-view-cell"
        case nightModeToggleViewCell = "night-mode-toggle-view-cell"
        case pregameRoomViewCell = "pregame-room-view-cell"
        case sectionHeaderCell = "section-header-view-cell"
        case timerToggleViewCell = "timer-toggle-view-cell"
        case versionViewCell = "version-view-cell"
    }

    enum notificationKey: String {
        case autoEliminate = "autoEliminate"
        case minigameGameOver = "minigameGameOver"
    }

    enum url: String {
        case version = "https://itunes.apple.com/lookup?bundleId=com.davidzhang.Spycodes"
        case support = "https://www.spycodes.net/support/"
        case appStore = "itms-apps://itunes.apple.com/app/id1141711201"
        case appStoreWeb = "https://itunes.apple.com/app/spycodes/id1141711201?mt=8"
        case github = "https://github.com/davidozhang/spycodes"
        case icons8 = "https://icons8.com/"
        case website = "https://www.spycodes.net/"
    }

    enum userDefaults: String {
        case nightMode = "nightMode"
    }
}
