class SCConstants {
    enum coding: String {
        case abort = "abort"
        case accessCode = "access-code"
        case bestRecord = "best-record"
        case card = "card"
        case cards = "cards"
        case categories = "categories"
        case categoryEmoji = "category-emoji"
        case categoryName = "category-name"
        case categoryTypes = "category-types"
        case categoryWordList = "category-word-list"
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
        case persistentSelection = "persistent-selection"      // Local coding only
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

    enum viewControllers: String {
        case accessCodeViewController = "access-code-view-controller"
        case categoriesViewController = "categories-view-controller"
        case customCategoryViewController = "custom-category-view-controller"
        case gameHelpViewController = "game-help-view-controller"
        case gameRoomViewController = "game-room"
        case gameSettingsViewController = "game-settings-view-controller"
        case mainMenuViewController = "main-menu-view-controller"
        case mainSettingsViewController = "main-settings-view-controller"
        case pageViewContainerViewController = "page-view-container-view-controller"
        case pageViewController = "page-view-controller"
        case playerNameViewController = "player-name-view-controller"
        case pregameRoomViewController = "pregame-room-view-controller"
        case timelineViewController = "timeline-view-controller"
        
    }

    enum images: String {
        case shuffle = "Shuffle"
        case markAsRead = "Mark-As-Read"
    }

    enum loggingIdentifier: String {
        case deinitialize = "DEINIT"
        case deviceType = "DEVICE TYPE"
        case localStorageManager = "SCLocalStorageManager"
        case notificationCenterManager = "SCNotificationCenterManager"
        case states = "SCStates"
    }

    enum nibs: String {
        case multilineToggleViewCell = "SCMultilineToggleViewCell"
        case textFieldViewCell = "SCTextFieldViewCell"
        case toggleViewCell = "SCToggleViewCell"
    }

    enum notificationKey: String {
        case customCategory = "custom-category-view"
        case customCategoryName = "custom-category-name"
        case disableSwipeGestureRecognizer = "disable-swipe-gesture-recognizer"
        case dismissModal = "dismiss-modal"
        case enableSwipeGestureRecognizer = "enable-swipe-gesture-recognizer"
        case intent = "intent"
        case minigameGameOver = "minigame-game-over"
        case pregameModal = "pregame-modal"
        case timelineUpdated = "timeline-updated"
        case updateCollectionView = "update-collection-view"
    }
    
    enum reuseIdentifiers: String {
        case accessibilityToggleViewCell = "accessibility-toggle-view-cell"
        case addWordViewCell = "add-word-view-cell"
        case deleteCategoryViewCell = "delete-category-view-cell"
        case disclosureViewCell = "disclosure-view-cell"
        case emojiSettingViewCell = "emoji-setting-view-cell"
        case gameRoomViewCell = "game-room-view-cell"
        case infoViewCell = "info-view-cell"
        case minigameToggleViewCell = "minigame-toggle-view-cell"
        case multilineToggleViewCell = "multi-line-toggle-view-cell"
        case nameSettingViewCell = "name-setting-view-cell"
        case nightModeToggleViewCell = "night-mode-toggle-view-cell"
        case persistentSelectionToggleViewCell = "persistent-selection-toggle-view-cell"
        case pregameRoomTeamEmptyStateViewCell = "pregame-room-team-empty-state-view-cell"
        case pregameRoomViewCell = "pregame-room-view-cell"
        case releaseNotesViewCell = "release-notes-view-cell"
        case sectionHeaderCell = "section-header-view-cell"
        case selectAllToggleViewCell = "select-all-toggle-view-cell"
        case singleLineToggleViewCell = "single-line-toggle-view-cell"
        case statisticsViewCell = "statistics-view-cell"
        case timelineModal = "timeline-modal"
        case timelineViewCell = "timeline-view-cell"
        case timerSettingViewCell = "timer-setting-view-cell"
        case versionViewCell = "version-view-cell"
        case wordViewCell = "word-view-cell"
    }
    
    enum segues: String {
        case accessCodeViewControllerSegue = "access-code-view-controller-segue"
        case customCategoryViewControllerSegue = "custom-category-view-controller-segue"
        case gameRoomViewControllerSegue = "game-room-view-controller-segue"
        case gameHelpViewControllerSegue = "game-help-view-controller-segue"
        case mainSettingsViewControllerSegue = "main-settings-view-controller-segue"
        case pageViewControllerSegue = "page-view-controller-segue"
        case pageViewContainerViewControllerSegue = "page-view-container-view-controller-segue"
        case pregameRoomViewControllerSegue = "pregame-room-view-controller-segue"
        case playerNameViewControllerSegue = "player-name-view-controller-segue"
        case timelineViewControllerSegue = "timeline-view-controller-segue"
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
        case navigationBarBlurView = 8
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
        case customCategories = "custom-categories"
        case nightMode = "night-mode"
        case persistentSelection = "persistent-selection"
        case selectedCategories = "selected-categories"
        case selectedCustomCategories = "selected-custom-categories"
    }
}
