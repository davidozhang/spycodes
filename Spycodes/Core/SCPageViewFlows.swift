class SCPageViewFlows {
    fileprivate static let mappings: [SCPageViewFlowType: [SCPageViewFlowEntry]] = [
        .PregameOnboarding: [
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.pregameOnboarding.welcome.rawLocalized,
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.pregameOnboarding.gameTypes.rawLocalized,
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.pregameOnboarding.regularGame.rawLocalized,
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.pregameOnboarding.minigame.rawLocalized,
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.pregameOnboarding.leaderNomination.rawLocalized,
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.pregameOnboarding.shuffleChangeButtons.rawLocalized,
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.pregameOnboarding.readyButton.rawLocalized,
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.pregameOnboarding.chevrons.rawLocalized,
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.pregameOnboarding.pregameMenu.rawLocalized,
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.pregameOnboarding.helpAccess.rawLocalized,
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.pregameOnboarding.dismiss.rawLocalized,
            ]),
        ],
        .GameOnboarding: SCPageViewFlows.retrieveCustomFlow(flowType: .GameOnboarding)
    ]

    fileprivate static let customMappings: [String: [SCPageViewFlowEntry]] = [
        SCConstants.pageViewFlowCustomKey.leaderShared.rawValue: [
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.message.leaderGoal.rawLocalized,
                SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                    SCStrings.header.goal.rawLocalized
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.message.leaderEnterClue.rawLocalized,
                SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                    SCStrings.header.enterClue.rawLocalized
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.message.leaderConfirm.rawLocalized,
                SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                    SCStrings.header.confirm.rawLocalized
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.message.leaderGuess.rawLocalized,
                SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                    SCStrings.header.guess.rawLocalized
            ]),
        ],
        SCConstants.pageViewFlowCustomKey.playerShared.rawValue: [
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.message.playerGoal.rawLocalized,
                SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                    SCStrings.header.goal.rawLocalized
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.message.playerWait.rawLocalized,
                SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                    SCStrings.header.waitForClue.rawLocalized
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.message.playerClue.rawLocalized,
                SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                    SCStrings.header.clue.rawLocalized
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.message.playerGuess.rawLocalized,
                SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                    SCStrings.header.guess.rawLocalized
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
                        SCStrings.message.minigameIntro.rawLocalized,
                    SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                        SCStrings.header.introduction.rawLocalized
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
                    SCConstants.pageViewFlowEntryKey.displayText.rawValue: SCStrings.message.minigameRoundEnd.rawLocalized,
                    SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                        SCStrings.header.roundEnd.rawLocalized
                    ])]
                result += [SCPageViewFlowEntry([
                    SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                        SCStrings.message.minigameEnd.rawLocalized,
                    SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                        SCStrings.header.ending.rawLocalized
                    ])]
            } else {
                result += [SCPageViewFlowEntry([
                    SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                        SCStrings.message.regularGameIntro.rawLocalized,
                    SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                        SCStrings.header.introduction.rawLocalized
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
                    SCConstants.pageViewFlowEntryKey.displayText.rawValue: SCStrings.message.regularGameRoundEnd.rawLocalized,
                    SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                        SCStrings.header.roundEnd.rawLocalized
                    ])]
                result += [SCPageViewFlowEntry([
                    SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                        SCStrings.message.regularGameEnd.rawLocalized,
                    SCConstants.pageViewFlowEntryKey.headerText.rawValue:
                        SCStrings.header.ending.rawLocalized
                    ])]
            }
        }

        return result
    }
}
