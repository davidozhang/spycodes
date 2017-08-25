import Foundation

extension String {
    var first: String {
        return String(characters.prefix(1))
    }

    var last: String {
        return String(characters.suffix(1))
    }

    var uppercasedFirst: String {
        return first.uppercased() + String(characters.dropFirst())
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
        case showAnswer = "Show Answer"
        case cancel = "Cancel"
        case confirm = "Confirm"
        case createGame = "Create Game"
        case dismiss = "Continue"
        case done = "Done"
        case endRound = "End Round"
        case gameAborted = "Aborted"
        case gameOver = "Game Over"
        case hideAnswer = "Hide Answer"
        case joinGame = "Join Game"
        case ready = "Ready"
        case returnToPregameRoom = "Return to Pregame Room"
        case ok = "OK"
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
        case nature = "Nature"
        case people = "People"
        case places = "Places"
        case space = "Space"
        case sports = "Sports"
        case transportation = "Transportation"
        case misc = "Miscellaneous"
    }

    enum emoji: String {
        case animals = "🐘"
        case architecture = "⛪️"
        case arts = "🖼"
        case body = "👀"
        case clothing = "👕"
        case completed = "✅"
        case foodAndDrinks = "🍹"
        case game = "🎲"
        case garden = "🌻"
        case incomplete = "❌"
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
    }

    enum header: String {
        case accessCode = "Access Code"
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
        case enterClue = "Enter Clue"
        case ending = "Final Note"
        case hostOnly = "Host Only Feature"
        case integrityCheck = "Integrity Check"
        case introduction = "Introduction"
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
    }

    enum info: String {
        case leaderNomination = "Tap on a teammate to nominate as leader."
        case minigameTeamSizeUnsatisfied = "Your team should have 2-3 players."
        case minigameTeamSizeSatisfied = "Your team currently has 2-3 players."
        case regularGameTeamSizeUnsatisfied = "Each team should have 2-4 players."
        case regularGameTeamSizeSatisfied = "Each team currently has 2-4 players."
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
        case leaderConfirm = "Once you are comfortable with your clue and number, tap Confirm to allow your teammates to see the clue and number. The clue and number cannot be modified until the round ends. You cannot talk or make eye contact with your teammates!"
        case leaderEnterClue = "Look over the words belonging to your team carefully and enter a 1-word clue followed by a number. The number represents the amount of words corresponding to your clue. Your clue cannot be a word already in the game!"
        case leaderGuess = "While guessing, your teammates can tap End Round at any time. If they guess the Assassin word, then it is Game Over. Guessing an enemy team word or a neutral word will end the round."
        case leaderGoal = "As a leader, you will see a color coded version of all the words. Your goal is to provide clues that would allow your teammates to guess all of your team's words in as few rounds as possible."
        case minigameEnd = "Your best record is based on the number of words remaining on the CPU team after each successful game. Try to aim for as high a number as possible!"
        case minigameIntro = "You are currently playing a Minigame with your teammates on Team Red versus a CPU player on Team Blue. There are 22 words in total: 8 Red, 7 Blue, 6 Neutral (white) and 1 Assassin (black)."
        case minigameRoundEnd = "After each round ends, the CPU automatically eliminates one of its words and hands the round back to your team. Your teammates must try to guess all of your team's words before the CPU finishes all of its words."
        case minigameWinString = "Your team won! There were %d opponent cards remaining. Great work!"
        case minimumWords = "There must be a minimum of %d words."
        case playerAborted = "A player in the game has aborted."
        case playerClue = "A 1-word clue and number will show at the top once your leader is done coming up with it. The number represents the amount of words corresponding to that clue. You cannot talk or make eye contact with your leader!"
        case playerDisconnected = "A player in the game has disconnected."
        case playerGoal = "As a regular player, your goal is to guess all the words belonging to your team in as few rounds as possible. You will be using the clues provided to you by your leader."
        case playerGuess = "Now it is your turn to guess! You can tap End Round at any time. If your team guesses the Assassin word, then it is Game Over. Guessing an enemy team word or a neutral word will end the round."
        case playerWait = "While your leader is coming up with the clue for the current round, you can wait and look over the words."
        case regularGameEnd = "Your team's wins and losses are tracked after each game. Try to win as many games as possible!"
        case regularGameIntro = "You are currently playing a regular game with your teammates. There are 22 words in total, including 6 Neutral (white) and 1 Assassin (black). Your team may get 7 or 8 starting words."
        case regularGameRoundEnd = "The other team will now follow the same process. Once they are done guessing they will hand the round back to your team. The round exchanges until one team guesses all of its words."
        case updatePrompt = "Please download the latest version of Spycodes."
    }

    enum player: String {
        case cpu = "CPU"
        case localPlayer = "You"
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
        case teamBlue = "Team Blue"
        case teamEmptyState = "No players on the team."
        case teamRed = "Team Red"
        case timer = "Timer"
        case version = "Version"
        case website = "Website"
    }

    enum round: String {
        case defaultIsTurnClue = "Waiting for Clue"
        case defaultLeaderClue = "Enter Clue"
        case defaultNonTurnClue = "Not Your Turn"
        case defaultNumberOfWords = "#"
    }

    enum secondaryLabel: String {
        case custom = "Custom"
        case minigame = "2-3 players play as a team against the CPU."
        case timer = "Set a time duration for each round."
        case numberOfWords = "%d %@"
        case numberOfWordsCustomCategory = "%d %@ (%@)"
        case persistentSelection = "Your current selections will be saved."
        case selectAll = "All categories will be selected."
        case tapToEdit = "Tap to Edit"
        case word = "word"
        case words = "words"
    }

    enum section: String {
        case about = "About"
        case categories = "Categories"
        case customize = "Customize"
        case gameSettings = "Game Settings"
        case info = "Info"
        case more = "More"
        case settings = "Settings"
        case statistics = "Statistics"
        case teamRed = "Team Red"
        case teamBlue = "Team Blue"
        case timeline = "Timeline"
        case word = "Word"
        case words = "Words"
        case wordListWithWordCount = "%@ (%d %@)"
        case wordList = "Word List"
    }

    enum state: String {
        case actionButton = "Action Button"
        case addingNewWord = "Adding New Word"
        case confirm = "Confirm"
        case customCategory = "Custom Category"
        case editingCategoryName = "Editing Category Name"
        case editingEmoji = "Editing Emoji"
        case editingExistingWord = "Editing Existing Word"
        case endRound = "End Round"
        case gameAborted = "Game Aborted"
        case gameOver = "Game Over"
        case hideAnswer = "Hide Answer"
        case log = "%@: %@"
        case main = "Main"
        case nonEditing = "Non-Editing"
        case notReady = "Not Ready"
        case pregameMenu = "Pregame Menu"
        case ready = "Ready"
        case readyButton = "Ready Button"
        case secondary = "Secondary"
        case showAnswer = "Show Answer"
        case started = "Started"
        case stopped = "Stopped"
        case timer = "Timer"
        case willStart = "Will Start"
    }

    enum status: String {
        case blue = "Blue"
        case fail = "Failed to join room"
        case normal = "Enter access code"
        case pending = "Joining room..."
        case ready = "READY"
        case red = "Red"
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
        case won = "won"
        case yourTeam = "Your team"
    }

    enum timer: String {
        case disabled = "None"
        case format = "%d:%02d"
        case minutes = "%d min"
        case stopped = "--:--"
    }
}
