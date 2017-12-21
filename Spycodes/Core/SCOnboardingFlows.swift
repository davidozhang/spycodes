class SCOnboardingFlows {
    enum FlowType: Int {
        case Pregame = 0
        case Game = 1
    }

    // TODO: Encapsulate mapping into new object
    fileprivate static let mapping: [FlowType: [Int: SCOnboardingFlowEntry]] = [
        .Pregame: [
            0:
                SCOnboardingFlowEntry([
                   SCConstants.onboardingFlowEntryKey.displayImageName.rawValue: "Spy",
                   SCConstants.onboardingFlowEntryKey.displayText.rawValue: "First onboarding view",
                ]),
            1:
                SCOnboardingFlowEntry([
                    SCConstants.onboardingFlowEntryKey.displayImageName.rawValue: "Change",
                    SCConstants.onboardingFlowEntryKey.displayText.rawValue: "Second onboarding view",
                ]),
            2:
                SCOnboardingFlowEntry([
                    SCConstants.onboardingFlowEntryKey.displayImageName.rawValue: "Shuffle",
                    SCConstants.onboardingFlowEntryKey.displayText.rawValue: "Third onboarding view",
                ]),
        ],
        .Game: [:]
    ]

    static func retrieveFlow(flowType: FlowType) -> [Int: SCOnboardingFlowEntry]? {
        if let mapping = SCOnboardingFlows.mapping[flowType] {
            return mapping
        }

        return nil
    }
}
