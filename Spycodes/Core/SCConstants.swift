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

    enum images: String {
        case shuffle = "Shuffle"
        case markAsRead = "Mark-As-Read"
    }

    enum loggingIdentifier: String {
        case deinitialize = "DEINIT"
        case deviceType = "DEVICE TYPE"
        case gameSettingsManager = "SCGameSettingsManager"
        case localStorageManager = "SCLocalStorageManager"
        case notificationCenterManager = "SCNotificationCenterManager"
        case states = "SCStates"
        case usageStatisticsManager = "SCUsageStatisticsManager"
    }

    enum nibs: String {
        case multilineToggleViewCell = "SCMultilineToggleViewCell"
        case pickerViewCell = "SCPickerViewCell"
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
        case pregameMenu = "pregame-menu"
        case timelineUpdated = "timeline-updated"
        case updateCollectionView = "update-collection-view"
    }

    enum pageViewFlowCustomKey: String {
        case playerShared = "player-shared"
        case leaderShared = "leader-shared"
        case minigameEnding = "minigame-ending"
        case regularGameEnding = "regular-game-ending"
    }
    
    enum pageViewFlowEntryKey: String {
        case displayImageName = "display-image"
        case displayImageType = "display-image-type"
        case displayText = "display-text"
        case headerText = "header-text"
        case showIphone = "show-iphone"
    }
    
    enum reuseIdentifiers: String {
        case accessibilityToggleViewCell = "accessibility-toggle-view-cell"
        case addWordViewCell = "add-word-view-cell"
        case deleteCategoryViewCell = "delete-category-view-cell"
        case disclosureViewCell = "disclosure-view-cell"
        case emojiSettingViewCell = "emoji-setting-view-cell"
        case gameRoomViewCell = "game-room-view-cell"
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
        case timelineModal = "timeline-modal"
        case timelineViewCell = "timeline-view-cell"
        case timerSettingViewCell = "timer-setting-view-cell"
        case versionViewCell = "version-view-cell"
        case wordViewCell = "word-view-cell"
    }
    
    enum segues: String {
        case accessCodeViewControllerSegue = "access-code-view-controller-segue"
        case accessCodeViewControllerUnwindSegue = "access-code-view-controller-unwind-segue"
        case customCategoryViewControllerSegue = "custom-category-view-controller-segue"
        case gameViewControllerSegue = "game-view-controller-segue"
        case gameHelpViewControllerSegue = "game-help-view-controller-segue"
        case mainViewControllerUnwindSegue = "main-view-controller-unwind-segue"
        case mainSettingsViewControllerSegue = "main-settings-view-controller-segue"
        case pageViewFlowViewControllerSegue = "page-view-flow-view-controller-segue"
        case pageViewFlowContainerViewControllerSegue = "page-view-flow-container-view-controller-segue"
        case pregameRoomViewControllerSegue = "pregame-room-view-controller-segue"
        case pregameRoomViewControllerUnwindSegue = "pregame-room-view-controller-unwind-segue"
        case playerNameViewControllerSegue = "player-name-view-controller-segue"
        case playerNameViewControllerUnwindSegue = "player-name-view-controller-unwind-segue"
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
        case github = "https://github.com/davidozhang/spycodes"
        case icons8 = "https://icons8.com/"
        case support = "https://www.spycodes.net/support/"
        case version = "https://itunes.apple.com/lookup?bundleId=com.davidzhang.Spycodes"
    }

    enum userDefaults: String {
        case accessibility = "accessibility"
        case appOpens = "app-opens"
        case customCategories = "custom-categories"
        case gamePlays = "game-plays"
        case nightMode = "night-mode"
        case persistentSelection = "persistent-selection"
        case selectedCategories = "selected-categories"
        case selectedCustomCategories = "selected-custom-categories"
    }
    
    enum viewControllers: String {
        case accessCodeViewController = "access-code-view-controller"
        case categoriesViewController = "categories-view-controller"
        case customCategoryViewController = "custom-category-view-controller"
        case gameHelpViewController = "game-help-view-controller"
        case gameSettingsViewController = "game-settings-view-controller"
        case gameViewController = "game-view-controller"
        case mainSettingsViewController = "main-settings-view-controller"
        case mainViewController = "main-view-controller"
        case pageViewFlowContainerViewController = "page-view-flow-container-view-controller"
        case pageViewFlowViewController = "page-view-flow-view-controller"
        case pageViewFlowEntryViewController = "page-view-flow-entry-view-controller"
        case playerNameViewController = "player-name-view-controller"
        case pregameRoomViewController = "pregame-room-view-controller"
        case timelineViewController = "timeline-view-controller"
    }
}
