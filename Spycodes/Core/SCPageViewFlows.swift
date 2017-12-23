class SCPageViewFlows {
    enum FlowType: Int {
        case Pregame = 0
        case Game = 1
    }

    fileprivate static let mapping: [FlowType: [Int: SCPageViewFlowEntry]] = [
        .Pregame: [
            0:
                SCPageViewFlowEntry([
                   SCConstants.onboardingFlowEntryKey.displayImageName.rawValue: "Spy",
                   SCConstants.onboardingFlowEntryKey.displayImageWidth.rawValue: 128,
                   SCConstants.onboardingFlowEntryKey.displayImageHeight.rawValue: 128,
                   SCConstants.onboardingFlowEntryKey.displayText.rawValue: "First onboarding view that has a lot of text, like a lot of text.. would this overflow? test test test test",
                ]),
            1:
                SCPageViewFlowEntry([
                    SCConstants.onboardingFlowEntryKey.displayText.rawValue: "Second onboarding view",
                ]),
            2:
                SCPageViewFlowEntry([
                    SCConstants.onboardingFlowEntryKey.displayImageName.rawValue: "Shuffle",
                    SCConstants.onboardingFlowEntryKey.displayText.rawValue: "Third onboarding view",
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
