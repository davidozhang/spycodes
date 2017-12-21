class SCPageViewFlowManager {
    fileprivate var flow: [Int: SCPageViewFlowEntry]?

    init(flowType: SCPageViewFlows.FlowType) {
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

        if let entry = flow[0] {
            return entry
        }

        return nil
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

        if let entry = flow[currentIndex] {
            return entry
        }

        return nil
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

        if let entry = flow[currentIndex] {
            return entry
        }
        
        return nil
    }
}
