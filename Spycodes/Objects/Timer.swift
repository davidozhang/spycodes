import Foundation

class Timer: NSObject {
    var timer: NSTimer?
    var startTime: Int?
    var duration: Int = 120
    
    var timerEndedCallback: (() -> Void)!
    var timerInProgressCallback: ((remainingTime: Int) -> Void)!
    
    func startTimer(timerEnded: () -> Void, timerInProgress: ((remainingTime: Int) -> Void)) {
        self.startTime = Int(NSDate.timeIntervalSinceReferenceDate())
        self.timerEndedCallback = timerEnded
        self.timerInProgressCallback = timerInProgress
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(Timer.updateTime), userInfo: nil, repeats: true)
    }
    
    func updateTime() {
        guard let startTime = self.startTime else { return }
        
        let currentTime = Int(NSDate.timeIntervalSinceReferenceDate())
        let remainingTime = self.duration - (currentTime - startTime)
        
        if remainingTime > 0 {
            self.timerInProgressCallback(remainingTime: remainingTime)
        } else {
            self.timer?.invalidate()
            self.timerEndedCallback()
        }
    }
}
