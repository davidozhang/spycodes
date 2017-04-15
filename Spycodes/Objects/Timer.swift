import Foundation

class Timer: NSObject, NSCoding {
    static var instance = Timer()

    var state: TimerState = .stopped

    fileprivate var enabled = false
    fileprivate var timer: Foundation.Timer?
    fileprivate var startTime: Int?
    fileprivate var duration: Int?

    fileprivate var timerEndedCallback: (() -> Void)?
    fileprivate var timerInProgressCallback: ((_ remainingTime: Int) -> Void)?

    override init() {
        super.init()
        self.setDuration(durationInMinutes: 2)
    }

    deinit {
        self.timer?.invalidate()
    }

    // MARK: Coder
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.enabled, forKey: SCConstants.coding.enabled.rawValue)

        if let duration = self.duration {
            aCoder.encode(duration, forKey: SCConstants.coding.duration.rawValue)
        }
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        self.enabled = aDecoder.decodeBool(
            forKey: SCConstants.coding.enabled.rawValue
        )

        if aDecoder.containsValue(forKey: SCConstants.coding.duration.rawValue) {
            self.duration = aDecoder.decodeInteger(
                forKey: SCConstants.coding.duration.rawValue
            )
        }
    }

    // MARK: Public
    func setDuration(durationInMinutes: Int) {
        self.duration = durationInMinutes * 60
    }

    func getDurationInMinutes() -> Int {
        if let duration = self.duration {
            return duration / 60
        }

        return 0
    }

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

        guard let startTime = self.startTime,
              let duration = self.duration else { return }

        let currentTime = Int(Date.timeIntervalSinceReferenceDate)
        let remainingTime = duration - (currentTime - startTime)

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
