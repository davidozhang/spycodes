import Foundation

class Timer: NSObject, NSCoding {
    static var instance = Timer()

    var state: TimerState = .stopped

    fileprivate var enabled = false
    fileprivate var timer: Foundation.Timer?
    fileprivate var startTime: Int?
    fileprivate var duration: Int = 120

    fileprivate var timerEndedCallback: (() -> Void)?
    fileprivate var timerInProgressCallback: ((_ remainingTime: Int) -> Void)?

    deinit {
        self.timer?.invalidate()
    }

    // MARK: Coder
    func encode(with aCoder: NSCoder) {
        aCoder.encode(enabled, forKey: SCCodingConstants.timerEnabled)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        self.enabled = aDecoder.decodeObject(
            forKey: SCCodingConstants.timerEnabled
        ) as? Bool ?? aDecoder.decodeBool(
            forKey: SCCodingConstants.timerEnabled
        )
    }

    // MARK: Public
    func setEnabled(_ enabled: Bool) {
        self.enabled = enabled
    }

    func isEnabled() -> Bool {
        return self.enabled
    }

    func startTimer(_ timerEnded: @escaping () -> Void,
                    timerInProgress: @escaping ((_ remainingTime: Int) -> Void)) {
        if !self.enabled {
            return
        }

        self.startTime = Int(Date.timeIntervalSinceReferenceDate)
        self.timerEndedCallback = timerEnded
        self.timerInProgressCallback = timerInProgress
        self.timer = Foundation.Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(Timer.updateTime),
            userInfo: nil,
            repeats: true
        )
    }

    func invalidate() {
        self.state = .stopped
        self.timer?.invalidate()
        self.timerEndedCallback = nil
        self.timerInProgressCallback = nil
    }

    func updateTime() {
        if !self.enabled {
            return
        }

        guard let startTime = self.startTime else { return }

        let currentTime = Int(Date.timeIntervalSinceReferenceDate)
        let remainingTime = self.duration - (currentTime - startTime)

        if remainingTime > 0 {
            if let timerInProgressCallback = self.timerInProgressCallback {
                timerInProgressCallback(remainingTime)
            }
        } else {
            self.timer?.invalidate()
            if let timerEndedCallback = self.timerEndedCallback {
                timerEndedCallback()
            }
        }
    }

    func reset() {
        self.enabled = false
        self.invalidate()
    }
}
