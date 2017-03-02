class SpycodesString {
    static let completed = "👍"
    static let incomplete = "😔"
    
    static let returningToMainMenuHeader = "Returning to Main Menu"
    static let returningToPregameRoomHeader = "Returning to Pregame Room"
    static let gameOverHeader = "Game Over"
    
    static let normalAccessCodeStatus = "Enter access code"
    static let normalLobbyRoomStatus = "Find a room to join"
    static let pendingStatus = "Joining room..."
    static let failStatus = "Failed to join room"
    
    static let minigameTeamSizeInfo = "Your team has 2-3 players."
    static let regularGameTeamSizeInfo = "Both teams have 2-4 players."
    static let minigameCluegiverInfo = "Your team has selected a leader."
    static let regularGameCluegiverInfo = "Both teams have selected leaders."
    static let endRoundInfo = "Your team must make at least one guess before you can end the round."
    static let minigameInfo = "2-3 players play against CPU."
    
    static let hostDisconnected = "Host player has disconnected."
    static let playerAborted = "A player in the game has aborted."
    static let playerDisconnected = "A player in the game has disconnected."
    
    // Help view strings
    static let minigameIntro = "You are currently playing a minigame with your teammates on Team Red versus a CPU player on Team Blue. There are 22 words in total: 8 Red, 7 Blue, 6 Neutral (white) and 1 Assassin (black)"
    static let regularIntro = "You are currently playing a regular game with your teammates. There are 22 words in total, including 6 Neutral (white) and 1 Assassin (black). Your team may get 7 or 8 starting words."
    
    static let leaderGoal = "As a leader, you will see a color-coded version of all the words. Your goal is to provide clues that allow your teammates to guess all of your team's words in as few rounds as possible"
    static let leaderEnterClue = "Look over the words carefully and enter a 1-word clue followed by a number. The number represents the number of words corresponding to your clue. Your clue cannot be a word already in the game!"
    static let leaderConfirm = "Once you are comfortable with your clue and number, tap Confirm to allow your teammates to see the clue and number. The clue and number cannot be modified until the round ends"
    static let leaderGuess = "Now it's time for your teammates to guess. Once they have made at least 1 successful guess, they can tap End Round. If they guess the Assassin word, then it's game over. Guessing neutral and enemy team's words will automatically end the round"
    
    static let playerGoal = "As a regular player, your goal is to guess all the words belonging to your team in as few rounds as possible. You will be using the clues provided to you by your leader"
    static let playerWait = "While your leader is coming up with the clue for the current round, you can wait and look over the words"
    static let playerClue = "A 1-word clue and number will show at the top once your leader is done coming up with it. The number represents the number of words corresponding to that clue"
    static let playerGuess = "Now it's your turn to guess! Once your team has made at least 1 successful guess, you can tap End Round. If your team guesses the Assassin word, then it's game over. Guessing neutral and enemy team's words will automatically end the round"
    
    static let regularGameRoundEnd = "The other team will now follow the same process. Once they are done guessing they will hand the round back to your team. The round exchanges until one team guesses all its words"
    static let minigameRoundEnd = "After each round ends, the CPU automatically eliminates one of the words belonging to its team and hands the round back to your team. Your teammates must guess all the words before the CPU does"
    static let regularGameEndMessage = "Your team's wins and losses are tracked after each game. Try to win as many games as possible!"
    static let minigameEndMessage = "Your best record is based on the number of words remaining on the CPU team after each successful game. Try to aim for as high a number as possible!"
}
