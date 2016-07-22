import AudioToolbox

class AudioToolboxManager {
    static let instance = AudioToolboxManager()
    
    func vibrate() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}