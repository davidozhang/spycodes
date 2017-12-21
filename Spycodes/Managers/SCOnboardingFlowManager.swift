class SCOnboardingFlowManager {
    static let instance = SCOnboardingFlowManager()

    fileprivate var flow: [Int: (String, String)]?

    func initializeForFlow(flowType: SCOnboardingFlows.FlowType) {
        self.flow = SCOnboardingFlows.retrieveFlow(flowType: flowType)
    }
    
    func getFlowCount() -> Int {
        guard let flow = self.flow else {
            return 0
        }

        return flow.count
    }
    
    func getInitial() -> (String, String)? {
        guard let flow = self.flow else {
            return nil
        }

        if let tuple = flow[0] {
            return tuple
        }

        return nil
    }
    
    func getPrevious(index: Int) -> (String, String)? {
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
    
    func getNext(index: Int) -> (String, String)? {
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
