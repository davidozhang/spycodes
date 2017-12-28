class SCPageViewFlowManager {
    fileprivate var flow: [SCPageViewFlowEntry]?

    init(flowType: SCPageViewFlowType) {
        self.flow = SCPageViewFlows.retrieveFlow(flowType: flowType)
    }
    
    func getFlowCount() -> Int {
        guard let flow = self.flow else {
            return 0
        }

        return flow.count
    }
    
    func getInitialEntry() -> SCPageViewFlowEntry? {
        guard let flow = self.flow else {
            return nil
        }

        return flow[0]
    }
    
    func getPreviousEntry(index: Int) -> SCPageViewFlowEntry? {
        guard let flow = self.flow else {
            return nil
        }

        var currentIndex = index
        currentIndex -= 1
        
        if currentIndex < 0 {
            return nil
        }

        return flow[currentIndex]
    }
    
    func getNextEntry(index: Int) -> SCPageViewFlowEntry? {
        guard let flow = self.flow else {
            return nil
        }

        var currentIndex = index
        currentIndex += 1

        if currentIndex >= flow.count {
            return nil
        }

        return flow[currentIndex]
    }
}
