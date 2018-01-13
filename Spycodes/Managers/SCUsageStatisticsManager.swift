class SCUsageStatisticsManager: SCLogger {
    static let instance = SCUsageStatisticsManager()
    
    fileprivate var discreteUsageStatistics = [SCDiscreteUsageStatisticsType: Int]()
    fileprivate var booleanUsageStatistics = [SCBooleanUsageStatisticsType: Bool]()
    
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

    func recordBooleanUsageStatistics(_ type: SCBooleanUsageStatisticsType, value: Bool) {
        self.booleanUsageStatistics[type] = value

        if let statistics = self.booleanUsageStatistics[type] {
            SCLocalStorageManager.instance.saveBooleanUsageStatistics(type, value: statistics)
        }
    }
    
    func getDiscreteUsageStatisticsValue(type: SCDiscreteUsageStatisticsType) -> Int? {
        return self.discreteUsageStatistics[type]
    }

    func getBooleanUsageStatisticsValue(type: SCBooleanUsageStatisticsType) -> Bool? {
        return self.booleanUsageStatistics[type]
    }
    
    func retrieveUsageStatisticsFromLocalStorage() {
        self.discreteUsageStatistics = SCLocalStorageManager.instance.retrieveDiscreteUsageStatistics()
        self.booleanUsageStatistics = SCLocalStorageManager.instance.retrieveBooleanUsageStatistics()

        super.log(self.discreteUsageStatistics.description)
        super.log(self.booleanUsageStatistics.description)
    }
}
