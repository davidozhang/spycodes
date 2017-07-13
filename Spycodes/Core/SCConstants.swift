class SCConstants {
    enum coding: String {
        case abort = "abort"
        case accessCode = "access-code"
        case bestRecord = "best-record"
        case card = "card"
        case cards = "cards"
        case categories = "categories"
        case clue = "clue"
        case correct = "correct"
        case emojis = "emojis"
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
        case wordCounts = "word-counts"
    }

    enum constant: Int {
        case accessCodeLength = 4
        case cardCount = 22
        case roomMaxSize = 8
        case numberOfTeams = 2
    }

    enum discoveryInfo: String {
        case accessCode = "access-code"
    }

    enum identifier: String {
        case accessCode = "access-code"
        case accessibilityToggleViewCell = "accessibility-toggle-view-cell"
        case customCategory = "custom-category"
        case customCategoryViewController = "custom-category-view-controller"
        case disclosureViewCell = "disclosure-view-cell"
        case emojiSettingViewCell = "emoji-setting-view-cell"
        case gameRoom = "game-room"
        case gameRoomViewCell = "game-room-view-cell"
        case helpView = "help-view"
        case infoViewCell = "info-view-cell"
        case mainMenu = "main-menu"
        case mainMenuModal = "main-menu-modal"
        case minigameToggleViewCell = "minigame-toggle-view-cell"
        case multilineToggleViewCell = "multi-line-toggle-view-cell"
        case nameSettingViewCell = "name-setting-view-cell"
        case nightModeToggleViewCell = "night-mode-toggle-view-cell"
        case pregameModalContainerView = "pregame-modal-container-view"
        case pregameModalMainView = "pregame-modal-main-view"
        case pregameModalSecondaryView = "pregame-modal-secondary-view"
        case pregameModalPageViewController = "pregame-modal-page-view-controller"
        case playerName = "player-name"
        case pregameRoom = "pregame-room"
        case pregameRoomTeamEmptyStateViewCell = "pregame-room-team-empty-state-view-cell"
        case pregameRoomViewCell = "pregame-room-view-cell"
        case releaseNotesViewCell = "release-notes-view-cell"
        case sectionHeaderCell = "section-header-view-cell"
        case settings = "settings"
        case singleLineToggleViewCell = "single-line-toggle-view-cell"
        case statisticsViewCell = "statistics-view-cell"
        case timelineModal = "timeline-modal"
        case timelineViewCell = "timeline-view-cell"
        case timerSettingViewCell = "timer-setting-view-cell"
        case versionViewCell = "version-view-cell"
    }

    enum images: String {
        case shuffle = "Shuffle"
        case markAsRead = "Mark-As-Read"
    }

    enum nibs: String {
        case multilineToggle = "SCMultilineToggleViewCell"
    }

    enum notificationKey: String {
        case customCategory = "custom-category-view"
        case disableSwipeGestureRecognizer = "disable-swipe-gesture-recognizer"
        case dismissModal = "dismiss-modal"
        case enableSwipeGestureRecognizer = "enable-swipe-gesture-recognizer"
        case intent = "intent"
        case minigameGameOver = "minigame-game-over"
        case pregameModal = "pregame-modal"
        case timelineUpdated = "timeline-updated"
        case updateCollectionView = "update-collection-view"
    }

    enum storyboards: String {
        case main = "Spycodes"
    }

    enum tag: Int {
        case firstTextField = 0
        case lastTextField = 3
        case dimView = 4
        case modalBlurView = 5
        case modalPeekBlurView = 6
        case sectionHeaderBlurView = 7
    }

    enum url: String {
        case appStore = "itms-apps://itunes.apple.com/app/id1141711201"
        case appStoreWeb = "https://itunes.apple.com/app/spycodes/id1141711201?mt=8"
        case github = "https://github.com/davidozhang/spycodes"
        case icons8 = "https://icons8.com/"
        case releaseNotes = "https://github.com/davidozhang/spycodes/releases"
        case support = "https://www.spycodes.net/support/"
        case version = "https://itunes.apple.com/lookup?bundleId=com.davidzhang.Spycodes"
        case website = "https://www.spycodes.net/"
    }

    enum userDefaults: String {
        case accessibility = "accessibility"
        case nightMode = "night-mode"
    }
}
