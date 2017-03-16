import UIKit

extension UIColor {
    static func spycodesRedColor() -> UIColor {
        return UIColor.init(red: 255/255, green: 83/255, blue: 77/255, alpha: 0.8)
    }
    
    static func spycodesBlueColor() -> UIColor {
        return UIColor.init(red: 0/255, green: 118/255, blue: 194/255, alpha: 0.8)
    }
    
    static func spycodesBlackColor() -> UIColor {
        return UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
    }
    
    static func spycodesGreenColor() -> UIColor {
        return UIColor.init(red: 0, green: 213/255, blue: 109/255, alpha: 0.8)
    }
    
    static func spycodesDarkGreenColor() -> UIColor {
        return UIColor.init(red: 0, green: 146/255, blue: 76/255, alpha: 1.0)
    }
    
    static func dimBackgroundColor() -> UIColor {
        return UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
    }
    
    static func colorForTeam(_ team: Team) -> UIColor {
        switch team {
        case Team.red:
            return UIColor.spycodesRedColor()
        case Team.blue:
            return UIColor.spycodesBlueColor()
        case Team.neutral:
            return UIColor.white
        default:
            return UIColor.spycodesBlackColor()
        }
    }
}
