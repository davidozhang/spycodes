import AudioToolbox

class SCAudioManager {
    static func vibrate() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }

    static func playClickSound() {
        DispatchQueue.main.async {
            AudioServicesPlaySystemSound(1104)
        }
    }
}
