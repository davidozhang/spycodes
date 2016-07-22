import UIKit

extension UIColor {
    static func spycodeLightRedColor() -> UIColor {
        return UIColor.init(red: 239/255, green: 83/255, blue: 80/255, alpha: 0.2)
    }
    
    static func spycodeRedColor() -> UIColor {
        return UIColor.init(red: 239/255, green: 83/255, blue: 80/255, alpha: 1.0)
    }
    
    static func spycodeLightBlueColor() -> UIColor {
        return UIColor.init(red: 66/255, green: 165/255, blue: 245/255, alpha: 0.2)
    }
    
    static func spycodeBlueColor() -> UIColor {
        return UIColor.init(red: 66/255, green: 165/255, blue: 245/255, alpha: 1.0)
    }
    
    static func spycodeLightOrangeColor() -> UIColor {
        return UIColor.init(red: 255/255, green: 202/255, blue: 40/255, alpha: 0.2)
    }
    
    static func spycodeBlackColor() -> UIColor {
        return UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.2)
    }
    
    static func colorForTeam(team: Team) -> UIColor {
        if team == Team.Red {
            return UIColor.spycodeLightRedColor()
        }
        else if team == Team.Blue {
            return UIColor.spycodeLightBlueColor()
        }
        else if team == Team.Neutral {
            return UIColor.spycodeLightOrangeColor()
        } else {
            return UIColor.spycodeBlackColor()
        }
    }
}