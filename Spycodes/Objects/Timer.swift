import Foundation

class Timer: NSObject {
    static let instance = Timer()
    private var enabled = false
    private var timer: NSTimer?
    private var startTime: Int?
    private var duration: Int = 120

    private var timerEndedCallback: (() -> Void)?
    private var timerInProgressCallback: ((remainingTime: Int) -> Void)?

    // MARK: Public
    func setEnabled(enabled: Bool) {
        self.enabled = enabled
    }

    func isEnabled() -> Bool {
        return self.enabled
    }

    func startTimer(timerEnded: () -> Void, timerInProgress: ((remainingTime: Int) -> Void)) {
        if !self.enabled {
            return
        }

        self.startTime = Int(NSDate.timeIntervalSinceReferenceDate())
        self.timerEndedCallback = timerEnded
        self.timerInProgressCallback = timerInProgress
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(Timer.updateTime), userInfo: nil, repeats: true)
    }

    func updateTime() {
        if !self.enabled {
            return
        }

        guard let startTime = self.startTime else { return }

        let currentTime = Int(NSDate.timeIntervalSinceReferenceDate())
        let remainingTime = self.duration - (currentTime - startTime)

        if remainingTime > 0 {
            if let timerInProgressCallback = self.timerInProgressCallback {
                timerInProgressCallback(remainingTime: remainingTime)
            }
        } else {
            self.timer?.invalidate()
            if let timerEndedCallback = self.timerEndedCallback {
                timerEndedCallback()
            }
        }
    }
}
