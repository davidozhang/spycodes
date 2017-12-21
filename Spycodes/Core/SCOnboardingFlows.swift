class SCOnboardingFlows {
    enum FlowType: Int {
        case Pregame = 0
        case Game = 1
    }

    // TODO: Encapsulate mapping into new object
    fileprivate static let mapping: [FlowType: [Int: (String, String)]] = [
        .Pregame: [
            0: ("Spy", "First onboarding view"),
            1: ("Change", "Second onboarding view"),
            2: ("Shuffle", "Third onboarding view"),
        ],
        .Game: [:]
    ]

    static func retrieveFlow(flowType: FlowType) -> [Int: (String, String)]? {
        if let mapping = SCOnboardingFlows.mapping[flowType] {
            return mapping
        }

        return nil
    }
}
