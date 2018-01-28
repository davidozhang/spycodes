import Foundation

extension String {
    var first: String {
        return String(prefix(1))
    }

    var last: String {
        return String(suffix(1))
    }

    var uppercasedFirst: String {
        return first.uppercased() + String(dropFirst())
    }

    var localized: String {
        return NSLocalizedString(
            self,
            tableName: nil,
            bundle: .main,
            value: "",
            comment: ""
        )
    }

    func localized(comment: String) -> String {
        return NSLocalizedString(
            self,
            tableName: nil,
            bundle: .main,
            value: "",
            comment: comment
        )
    }
}

class SCStrings {
    static let appName = "Spycodes"

    enum button: String {
        case cancel = "Cancel"
        case confirm = "Confirm"
        case dismiss = "Continue"
        case download = "Download"
        case createGame = "Create Game"
        case done = "Done"
        case endRound = "End Round"
        case gameAborted = "Aborted"
        case gameOver = "Game Over"
        case hideAnswer = "Hide Answer"
        case joinGame = "Join Game"
        case ok = "OK"
        case ready = "Ready"
        case returnToPregameRoom = "Return to Pregame Room"
        case showAnswer = "Show Answer"

        var rawLocalized: String {
            return self.rawValue.localized
        }
    }

    enum category: String {
        case animals = "Animals"
        case architecture = "Architecture"
        case arts = "Arts"
        case body = "Body"
        case clothing = "Clothing"
        case foodAndDrinks = "Food & Drinks"
        case game = "Game"
        case garden = "Garden"
        case items = "Items"
        case misc = "Miscellaneous"
        case nature = "Nature"
        case people = "People"
        case places = "Places"
        case space = "Space"
        case sports = "Sports"
        case transportation = "Transportation"

        var rawLocalized: String {
            return self.rawValue.localized
        }
    }

    enum emoji: String {
        case animals = "🐘"
        case architecture = "⛪️"
        case arts = "🖼"
        case body = "👀"
        case clothing = "👕"
        case foodAndDrinks = "🍹"
        case game = "🎲"
        case garden = "🌻"
        case items = "🎈"
        case info = "ℹ️"
        case nature = "🌲"
        case people = "🚶"
        case places = "🗼"
        case space = "🌎"
        case sports = "⚽️"
        case transportation = "✈️"
        case misc = "❓"
        case rocket = "🚀"
        case setting = "⚙"

        var rawLocalized: String {
            return self.rawValue.localized
        }
    }

    enum gameOnboarding: String {
        case clueRule = "The team leader is encouraged to come up with clever clues. However, cheap tactics should be avoided to keep the game fun and challenging for everyone!"
        case communication = "The team leader should not communicate with teammates through verbal or physical cues. The leader's screen should not be visible to other players."
        case dismiss = "Good luck and have fun! Swipe down to continue with the game."
        case leaderConfirm = "Once you confirm the clue word and number, tap Confirm to allow your teammates to see them. The clue word and number cannot be modified until the round ends."
        case leaderEnterClue = "Look over the your team's words and enter a 1-word clue followed by a number. The number represents the amount of words corresponding to your clue. Your clue cannot be a word already in the game!"
        case leaderGuess = "Your teammates can tap on a word card to guess the word. If they guess the Assassin word, then the game is over. Guessing an enemy or neutral word will end the current round."
        case leaderGoal = "As a leader, you will see a color coded version of all the words. Your goal is to provide clues that would allow your teammates to guess all your team's words in as few rounds as possible."
        case minigameIntroduction = "Let's guide you through the basics of minigame. You are playing on Team Red against the CPU on Team Blue."
        case minigameWordCount = "There are 22 word cards in total with the following assignment: 8 Red, 7 Blue, 6 White (Neutral) and 1 Black (Assassin)."
        case endRound = "Your teammates can end the round by tapping End Round any time after all guesses have been made."
        case cpuRound = "During the CPU round, the CPU eliminates one of its words and gives the round back to your team."
        case playerClue = "Your team leader will post a clue consisting of a word and number. The number indicates how many words on the game board should correspond to the clue word."
        case playerGoal = "As a regular player, your goal is to guess all the words belonging to your team in as few rounds as possible. You will be using the clues provided by your team leader."
        case playerGuess = "Tap on a word card to guess the word. If your team guesses the Assassin word, then the game is over. Guessing an enemy or neutral word will end the round."
        case playerWait = "While your team leader is coming up with the clue for the current round, look over and familiarize yourself with the words."
        case regularGameIntroduction = "Let's guide you through the basics of the regular game."
        case regularGameWordCount = "There are 22 word cards in total with 6 White (Neutral) and 1 Black (Assassin). Your team may receive 7 or 8 starting words."
        case enemyTeamRound = "The other team will now follow the same process. Once they are done guessing they will give the round back to your team. The rounds exchange until one team guesses all of its words."

        var rawLocalized: String {
            return self.rawValue.localized
        }
    }

    enum header: String {
        case accessCode = "Access Code"
        case additionalRules = "Additional Rules"
        case categoryExists = "Existing Category"
        case categoryName = "Category Name"
        case categoryWordList = "Category Word List"
        case clue = "Clue"
        case confirm = "Confirm"
        case confirmDeletion = "Confirm Deletion"
        case duplicateWord = "Duplicate Word"
        case editWord = "Edit Word"
        case emptyCategory = "Empty Category"
        case emptyWord = "Empty Word"
        case ending = "Final Note"
        case enterClue = "Enter Clue"
        case hostOnly = "Host Only Feature"
        case integrityCheck = "Integrity Check"
        case introduction = "Introduction"
        case invalidClue = "Invalid Clue"
        case gameAborted = "Game Aborted"
        case gameOver = "Game Over"
        case goal = "Goal"
        case guess = "Guessing Time"
        case playerName = "Your Name"
        case pregameRoom = "%@: %@"
        case returningToMainMenu = "Returning to Main Menu"
        case roundEnd = "Round End"
        case minimumWords = "Too Few Words"
        case updateApp = "Update App"
        case waitForClue = "Waiting For Clue"

        var rawLocalized: String {
            return self.rawValue.localized
        }
    }

    enum logging: String {
        case addedObservers = "%d observers '%@' registered for view controller with identifier '%@'."
        case allCustomCategoriesRetrieved = "All custom categories retrieved."
        case allCustomCategoriesSaved = "All custom categories saved."
        case booleanUsageStatisticsRetrieved = "Boolean usage statistics retrieved."
        case deinitStatement = "View controller with identifier '%@' deinitialized."
        case discreteUsageStatisticsRetrieved = "Discrete usage statistics retrieved."
        case localSettingsRetrieved = "Local settings retrieved."
        case localSettingsSaved = "Local settings saved."
        case removedObservers = "%d observers '%@' removed for view controller with identifier '%@'."
        case selectedCategoriesSaved = "Selected categories saved."
        case selectedConsolidatedCategoriesCleared = "Selected consolidated categories cleared."
        case selectedConsolidatedCategoriesRetrieved = "Selected consolidated categories retrieved."
        case selectedCustomCategoriesSaved = "Selected custom categories saved."
        case unidentifiedViewControllerAddingObservers = "Unidentified view controller adding observers!"
        case unidentifiedViewControllerRemovingObservers = "Unidentified view controller removing observers!"

        var rawLocalized: String {
            return self.rawValue.localized
        }
    }

    enum message: String {
        case categoryExists = "The category name already exists."
        case categorySetting = "Only the host can toggle category settings."
        case categoryWordList = "The word list should contain at least 1 word."
        case defaultLoseString = "Your team lost!"
        case defaultWinString = "Your team won!"
        case confirmDeletion = "Are you sure you want to delete the category?"
        case duplicateWord = "The word is already in the list."
        case emptyCategoryName = "Category name cannot be empty."
        case emptyWord = "Word cannot be empty."
        case enterCategoryName = "Enter a category name"
        case hostDisconnected = "Host player has disconnected."
        case integrityCheck = "There must be at least 22 words for all selected categories."
        case invalidClue = "The clue is an invalid word. Please enter another one."
        case minigameWinString = "Your team won! There were %d opponent cards remaining. Great work!"
        case minimumWords = "There must be a minimum of 22 words."
        case playerAborted = "A player in the game has aborted."
        case playerDisconnected = "A player in the game has disconnected."
        case updatePrompt = "Please download the latest version of Spycodes."

        var rawLocalized: String {
            return self.rawValue.localized
        }
    }

    enum player: String {
        case cpu = "CPU"
        case localPlayer = "You"

        var rawLocalized: String {
            return self.rawValue.localized
        }
    }

    enum pregameOnboarding: String {
        case chevrons = "Chevrons in the app can be tapped on. They also indicate swipe support in the direction they are pointing to."
        case dismiss = "You are all set for now. Swipe down to dismiss this view!"
        case gameTypes = "There are two types of games you could play: regular and minigame."
        case minigame = "In a minigame, you all play on Team Red against the CPU on Team Blue. Your team should have 2-3 players."
        case helpAccess = "You can always access this help view by tapping on the help button in the top right corner."
        case leaderNomination = "Tap a teammate to nominate as leader. The leader will be providing clues to your team for the next game."
        case pregameMenu = "Swipe up in the pregame room view to access game and word category settings."
        case regularGame = "In a regular game, you can pick a team to be on. Each team should have at least 2 players."
        case shuffleButton = "Tap the shuffle button to randomly assign your team's leader."
        case changeButton = "Tap the change button to change your team assignment."
        case readyButton = "Tap Ready when you are set. The game starts when everyone is ready."
        case welcome = "Welcome to Spycodes! Let's help you get started."

        var rawLocalized: String {
            return self.rawValue.localized
        }
    }

    enum primaryLabel: String {
        case accessibility = "Accessibility"
        case addWord = "Add Word"
        case bestRecord = "Best Record"
        case category = "%@ %@"
        case categoryNoEmoji = "%@"
        case deleteCategory = "Delete Category"
        case emoji = "Emoji (Optional)"
        case icons8 = "Icons8"
        case github = "Github"
        case minigame = "Minigame"
        case minigameStatistics = "%@: %@"
        case name = "Name"
        case nightMode = "Night Mode"
        case none = "--"
        case persist = "Persist"
        case regularGameStatistics = "%@ %@ : %@ %@"
        case releaseNotes = "Release Notes"
        case reviewApp = "Review App"
        case selectAll = "Select All"
        case support = "Support"
        case teamBlue = "Blue"
        case teamEmptyState = "No players on the team."
        case teamRed = "Red"
        case timer = "Timer"
        case validateClues = "Clue Validation"
        case version = "Version"
        case website = "Website"

        var rawLocalized: String {
            return self.rawValue.localized
        }
    }

    enum round: String {
        case defaultIsTurnClue = "Waiting for Clue"
        case defaultLeaderClue = "Enter Clue"
        case defaultNonTurnClue = "Not Your Turn"
        case defaultNumberOfWords = "#"

        var rawLocalized: String {
            return self.rawValue.localized
        }
    }

    enum secondaryLabel: String {
        case accessibility = "Add indicators to differentiate card colors."
        case custom = "Custom"
        case minigame = "2-3 players play as a team against the CPU."
        case nightMode = "Reduce the brightness of the background."
        case timer = "Set a time duration for each round."
        case numberOfWords = "%d %@"
        case numberOfWordsCustomCategory = "%d %@ (%@)"
        case persistentSelection = "Your current selections will be saved."
        case selectAll = "All categories will be selected."
        case tapToEdit = "Tap to Edit"
        case validateClues = "Checks if clue word is valid (English only)."
        case word = "word"
        case words = "words"

        var rawLocalized: String {
            return self.rawValue.localized
        }
    }

    enum section: String {
        case about = "About"
        case categories = "Categories"
        case customize = "Customize"
        case gameSettings = "Game Settings"
        case more = "More"
        case settings = "Settings"
        case teamRed = "Team Red"
        case teamBlue = "Team Blue"
        case timeline = "Timeline"
        case word = "Word"
        case words = "Words"
        case wordListWithWordCount = "%@ (%d %@)"
        case wordList = "Word List"

        var rawLocalized: String {
            return self.rawValue.localized
        }
    }

    enum state: String {
        case actionButton = "Action Button"
        case addingNewWord = "Adding New Word"
        case categories = "Categories"
        case confirm = "Confirm"
        case customCategory = "Custom Category"
        case editingCategoryName = "Editing Category Name"
        case editingEmoji = "Editing Emoji"
        case editingExistingWord = "Editing Existing Word"
        case endRound = "End Round"
        case gameAborted = "Game Aborted"
        case gameOver = "Game Over"
        case gameSettings = "Game Settings"
        case hideAnswer = "Hide Answer"
        case log = "%@: %@."
        case nonEditing = "Non-Editing"
        case notReady = "Not Ready"
        case pregameMenu = "Pregame Menu"
        case ready = "Ready"
        case readyButton = "Ready Button"
        case showAnswer = "Show Answer"
        case started = "Started"
        case stopped = "Stopped"
        case timer = "Timer"
        case willStart = "Will Start"

        var rawLocalized: String {
            return self.rawValue.localized
        }
    }

    enum status: String {
        case blue = "Blue"
        case fail = "Failed to join room"
        case normal = "Enter access code"
        case pending = "Joining room..."
        case ready = "READY"
        case red = "Red"

        var rawLocalized: String {
            return self.rawValue.localized
        }
    }

    enum timeline: String {
        case and = "&"
        case assassin = "the assassin"
        case bystander = "a bystander"
        case correctlySelected = "correctly selected"
        case correctlySelectedEvent = "%@ %@ '%@'."     // [Player] [correctly selected] '[Word]'.
        case confirmEvent = "%@ %@ '%@ %@'."    // [Player] [set the clue to] '[Clue] [1]'.
        case cpuSelected = "CPU selected"
        case cpuSelectedEvent = "%@ '%@' %@ %@."    // [CPU selected] '[Word]' [&] [ended the round].
        case emptyState = "No events yet."
        case endedGame = "ended the game"
        case endedRound = "ended the round"
        case endRoundEvent = "%@ %@."   // [Player] [ended the round].
        case enemy = "an enemy card"
        case gameAbortedEvent = "Game has been aborted."
        case gameOver = "Game over"
        case gameOverEvent = "%@. %@ %@."   // [Game over]. [Your team] [won].
        case incorrectlySelectedEvent = "%@ %@ %@ '%@' %@ %@."   // [Player] [selected] [an enemy card] '[Word]' [&] [ended the round].
        case lost = "lost"
        case selected = "selected"
        case setClueTo = "set the clue to"
        case timerExpiry = "Round has ended due to timer expiry."
        case unknownEvent = "Unknown event. Please update Spycodes!"
        case won = "won"
        case yourTeam = "Your team"

        var rawLocalized: String {
            return self.rawValue.localized
        }
    }

    enum timer: String {
        case disabled = "None"
        case format = "%d:%02d"
        case minutes = "%d min"
        case stopped = "--:--"

        var rawLocalized: String {
            return self.rawValue.localized
        }
    }
}
