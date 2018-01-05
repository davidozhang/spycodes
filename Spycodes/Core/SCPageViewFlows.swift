class SCPageViewFlows {
    fileprivate static let mappings: [SCPageViewFlowType: [SCPageViewFlowEntry]] = [
        .PregameOnboarding: [
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue: "Welcome to Spycodes! Let's help you get started.",
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayImageName.rawValue: "out",
                SCConstants.pageViewFlowEntryKey.displayImageType.rawValue: SCPageViewFlowEntry.DisplayImageType.GIF,
                SCConstants.pageViewFlowEntryKey.displayText.rawValue: "There are two types of games you could play: regular and minigame.",
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue: "In a regular game, you can pick a team to be on. Each team should have at least 2 players.",
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue: "In a minigame, you all play on Team Red against the CPU on Team Blue. Your team should have 2-3 players.",
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue: "Tap a teammate to nominate as leader. The leader will be providing clues to your team for the next game.",
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue: "Tap the shuffle button to randomly assign your team's leader. Tap the change button to change your team assignment.",
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue: "Tap Ready when you are set. The game starts when everyone is ready.",
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue: "Chevrons in the app can be tapped on. They also indicate swipe support in the direction it is pointing.",
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue: "Swipe up in the pregame view to access game and category settings.",
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue: "Remember, you can always access this help view by tapping on the help button.",
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue: "You are all set for now. Swipe down to dismiss this view!",
            ]),
        ],
        .GameOnboarding: SCPageViewFlows.retrieveCustomFlow(flowType: .GameOnboarding)
    ]

    fileprivate static let customMappings: [String: [SCPageViewFlowEntry]] = [
        SCConstants.pageViewFlowCustomKey.leaderShared.rawValue: [
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.message.leaderGoal.rawValue.localized,
                SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                    SCStrings.header.goal.rawValue.localized
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue: SCStrings.message.leaderEnterClue.rawValue.localized,
                SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                    SCStrings.header.enterClue.rawValue.localized
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.message.leaderConfirm.rawValue.localized,
                SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                    SCStrings.header.confirm.rawValue.localized
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.message.leaderGuess.rawValue.localized,
                SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                    SCStrings.header.guess.rawValue.localized
            ]),
        ],
        SCConstants.pageViewFlowCustomKey.playerShared.rawValue: [
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.message.playerGoal.rawValue.localized,
                SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                    SCStrings.header.goal.rawValue.localized
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.message.playerWait.rawValue.localized,
                SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                    SCStrings.header.waitForClue.rawValue.localized
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.message.playerClue.rawValue.localized,
                SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                    SCStrings.header.clue.rawValue.localized
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.message.playerGuess.rawValue.localized,
                SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                    SCStrings.header.guess.rawValue.localized
            ]),
        ],
    ]

    static func retrieveFlow(flowType: SCPageViewFlowType) -> [SCPageViewFlowEntry]? {
        if let mappings = SCPageViewFlows.mappings[flowType] {
            return mappings
        }

        return nil
    }

    fileprivate static func retrieveCustomFlow(flowType: SCPageViewFlowType) -> [SCPageViewFlowEntry] {
        var result = [SCPageViewFlowEntry]()

        if flowType == .GameOnboarding {
            if SCGameSettingsManager.instance.isGameSettingEnabled(.minigame) {
                result += [SCPageViewFlowEntry([
                    SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                        SCStrings.message.minigameIntro.rawValue.localized,
                    SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                        SCStrings.header.introduction.rawValue.localized
                    ])]

                if Player.instance.isLeader() {
                    if let leaderSharedFlow = SCPageViewFlows.customMappings[SCConstants.pageViewFlowCustomKey.leaderShared.rawValue] {
                        result += leaderSharedFlow
                    }
                } else {
                    if let playerSharedFlow = SCPageViewFlows.customMappings[SCConstants.pageViewFlowCustomKey.playerShared.rawValue] {
                        result += playerSharedFlow
                    }
                }

                result += [SCPageViewFlowEntry([
                    SCConstants.pageViewFlowEntryKey.displayText.rawValue: SCStrings.message.minigameRoundEnd.rawValue.localized,
                    SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                        SCStrings.header.roundEnd.rawValue.localized
                    ])]
                result += [SCPageViewFlowEntry([
                    SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                        SCStrings.message.minigameEnd.rawValue.localized,
                    SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                        SCStrings.header.ending.rawValue.localized
                    ])]
            } else {
                result += [SCPageViewFlowEntry([
                    SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                        SCStrings.message.regularGameIntro.rawValue.localized,
                    SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                        SCStrings.header.introduction.rawValue.localized
                    ])]

                if Player.instance.isLeader() {
                    if let leaderSharedFlow = SCPageViewFlows.customMappings[SCConstants.pageViewFlowCustomKey.leaderShared.rawValue] {
                        result += leaderSharedFlow
                    }
                } else {
                    if let playerSharedFlow = SCPageViewFlows.customMappings[SCConstants.pageViewFlowCustomKey.playerShared.rawValue] {
                        result += playerSharedFlow
                    }
                }

                result += [SCPageViewFlowEntry([
                    SCConstants.pageViewFlowEntryKey.displayText.rawValue: SCStrings.message.regularGameRoundEnd.rawValue.localized,
                    SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                        SCStrings.header.roundEnd.rawValue.localized
                    ])]
                result += [SCPageViewFlowEntry([
                    SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                        SCStrings.message.regularGameEnd.rawValue.localized,
                    SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                        SCStrings.header.ending.rawValue.localized
                    ])]
            }
        }

        return result
    }
}
