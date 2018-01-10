class SCUsageStatisticsManager: SCLogger {
    static let instance = SCUsageStatisticsManager()
    
    fileprivate var discreteUsageStatistics = [SCDiscreteUsageStatisticsType: Int]()
    
    override func getIdentifier() -> String? {
        return SCConstants.loggingIdentifier.usageStatisticsManager.rawValue
    }

    func recordDiscreteUsageStatistics(_ type: SCDiscreteUsageStatisticsType) {
        if let statistics = self.discreteUsageStatistics[type] {
            self.discreteUsageStatistics[type] = statistics + 1
        }

        if let statistics = self.discreteUsageStatistics[type] {
            SCLocalStorageManager.instance.saveDiscreteUsageStatistics(type, value: statistics)
        }
    }
    
    func getDiscreteUsageStatisticsValue(type: SCDiscreteUsageStatisticsType) -> Int? {
        return self.discreteUsageStatistics[type]
    }
    
    func retrieveDiscreteUsageStatisticsFromLocalStorage() {
        self.discreteUsageStatistics = SCLocalStorageManager.instance.retrieveDiscreteUsageStatistics()
        super.log(self.discreteUsageStatistics.description)
    }
}
