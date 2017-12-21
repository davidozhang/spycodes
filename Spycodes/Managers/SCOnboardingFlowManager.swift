class SCOnboardingFlowManager {
    static let instance = SCOnboardingFlowManager()

    fileprivate var flow: [Int: SCOnboardingFlowEntry]?

    func initializeForFlow(flowType: SCOnboardingFlows.FlowType) {
        self.flow = SCOnboardingFlows.retrieveFlow(flowType: flowType)
    }
    
    func getFlowCount() -> Int {
        guard let flow = self.flow else {
            return 0
        }

        return flow.count
    }
    
    func getInitialEntry() -> SCOnboardingFlowEntry? {
        guard let flow = self.flow else {
            return nil
        }

        if let tuple = flow[0] {
            return tuple
        }

        return nil
    }
    
    func getPreviousEntry(index: Int) -> SCOnboardingFlowEntry? {
        guard let flow = self.flow else {
            return nil
        }

        var currentIndex = index
        currentIndex -= 1
        
        if currentIndex < 0 {
            return nil
        }

        if let tuple = flow[currentIndex] {
            return tuple
        }

        return nil
    }
    
    func getNextEntry(index: Int) -> SCOnboardingFlowEntry? {
        guard let flow = self.flow else {
            return nil
        }

        var currentIndex = index
        currentIndex += 1

        if currentIndex >= flow.count {
            return nil
        }

        if let tuple = flow[currentIndex] {
            return tuple
        }
        
        return nil
    }
}
