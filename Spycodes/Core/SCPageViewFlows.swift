class SCPageViewFlows {
    fileprivate static let mappings: [SCPageViewFlowType: [SCPageViewFlowEntry]] = [
        .PregameOnboarding: [
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.pregameOnboarding.welcome.rawValue.localized,
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.pregameOnboarding.gameTypes.rawValue.localized,
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.pregameOnboarding.regularGame.rawValue.localized,
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.pregameOnboarding.minigame.rawValue.localized,
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.pregameOnboarding.leaderNomination.rawValue.localized,
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.pregameOnboarding.shuffleChangeButtons.rawValue.localized,
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.pregameOnboarding.readyButton.rawValue.localized,
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.pregameOnboarding.chevrons.rawValue.localized,
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.pregameOnboarding.pregameMenu.rawValue.localized,
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.pregameOnboarding.helpAccess.rawValue.localized,
            ]),
            SCPageViewFlowEntry([
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.pregameOnboarding.dismiss.rawValue.localized,
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
                SCConstants.pageViewFlowEntryKey.displayText.rawValue:
                    SCStrings.message.leaderEnterClue.rawValue.localized,
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
