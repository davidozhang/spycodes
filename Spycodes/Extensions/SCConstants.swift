class SCConstants {
    enum coding: String {
        case abort = "abort"
        case accessCode = "access-code"
        case bestRecord = "best-record"
        case cards = "cards"
        case clue = "clue"
        case eventType = "event-type"
        case hasRead = "has-read"       // Local coding only
        case leader = "leader"
        case localPlayer = "local-player"   // Local coding only
        case connectedPeers = "connected-peers"
        case duration = "duration"
        case enabled = "enabled"
        case gameEnded = "game-ended"
        case host = "host"
        case mode = "mode"
        case name = "name"
        case numberOfWords = "number-of-words"
        case parameters = "parameters"
        case players = "players"
        case ready = "ready"
        case score = "score"
        case selected = "selected"
        case team = "team"
        case timestamp = "timestamp"
        case uuid = "uuid"
        case winningTeam = "winning-team"
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
        case accessibilityToggleViewCell = "accessibility-toggle-view-cell"
        case checklistViewCell = "checklist-view-cell"
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
        case pregameRoomTeamEmptyStateViewCell = "pregame-room-team-empty-state-view-cell"
        case pregameRoomViewCell = "pregame-room-view-cell"
        case statisticsViewCell = "statistics-view-cell"
        case sectionHeaderCell = "section-header-view-cell"
        case settings = "settings"
        case timelineModal = "timeline-modal"
        case timelineViewCell = "timeline-view-cell"
        case timerToggleViewCell = "timer-toggle-view-cell"
        case updateApp = "update-app"
        case versionViewCell = "version-view-cell"
    }

    enum notificationKey: String {
        case minigameGameOver = "minigame-game-over"
        case timelineUpdated = "timeline-updated"
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
        case accessibility = "accessibility"
        case nightMode = "night-mode"
    }
}
