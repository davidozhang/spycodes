class SCPageViewFlows {
    enum FlowType: Int {
        case Pregame = 0
        case Game = 1
    }

    fileprivate static let mapping: [FlowType: [Int: SCPageViewFlowEntry]] = [
        .Pregame: [
            0:
                SCPageViewFlowEntry([
                    SCConstants.onboardingFlowEntryKey.displayText.rawValue: "Welcome to Spycodes! Let's help you get started.",
                ]),
            1:
                SCPageViewFlowEntry([
                    SCConstants.onboardingFlowEntryKey.displayText.rawValue: "There are two types of games you could play: regular and minigame.",
                ]),
            2:
                SCPageViewFlowEntry([
                    SCConstants.onboardingFlowEntryKey.displayText.rawValue: "In a regular game, you can pick a team to be on. Each team should have at least 2 players.",
                ]),
            3:
                SCOnboardingFlowEntry([
                    SCConstants.onboardingFlowEntryKey.displayText.rawValue: "In a minigame, you all play on Team Red against the CPU on Team Blue. Your team should have 2-3 players.",
                    ]),
            4:
                SCOnboardingFlowEntry([
                    SCConstants.onboardingFlowEntryKey.displayText.rawValue: "Tap a teammate to nominate as leader. The leader will be providing clues to your team for the next game.",
                    ]),
            5:
                SCOnboardingFlowEntry([
                    SCConstants.onboardingFlowEntryKey.displayText.rawValue: "Tap the shuffle button to randomly assign your team's leader. Tap the change button to change your team assignment.",
                    ]),
            6:
                SCOnboardingFlowEntry([
                    SCConstants.onboardingFlowEntryKey.displayText.rawValue: "Tap Ready when you are set. The game starts when everyone is ready.",
                    ]),
            7:
                SCOnboardingFlowEntry([
                    SCConstants.onboardingFlowEntryKey.displayText.rawValue: "Chevrons in the app can be tapped on. They also indicate swipe support in the direction it is pointing.",
                    ]),
            8:
                SCOnboardingFlowEntry([
                    SCConstants.onboardingFlowEntryKey.displayText.rawValue: "Swipe up in the pregame view to access game and category settings.",
                    ]),
            9:
                SCOnboardingFlowEntry([
                    SCConstants.onboardingFlowEntryKey.displayText.rawValue: "Remember, you can always access this help view by tapping on the help button.",
                    ]),
            10:
                SCOnboardingFlowEntry([
                    SCConstants.onboardingFlowEntryKey.displayText.rawValue: "You are all set for now. Swipe down to dismiss this view!",
                    ]),
        ],
        .Game: [:]
    ]

    static func retrieveFlow(flowType: FlowType) -> [Int: SCPageViewFlowEntry]? {
        if let mapping = SCPageViewFlows.mapping[flowType] {
            return mapping
        }

        return nil
    }
}
