import UIKit

extension UIColor {
    static func spycodesLightRedColor() -> UIColor {
        return UIColor.init(red: 239/255, green: 83/255, blue: 80/255, alpha: 0.2)
    }
    
    static func spycodesRedColor() -> UIColor {
        return UIColor.init(red: 239/255, green: 83/255, blue: 80/255, alpha: 1.0)
    }
    
    static func spycodesLightBlueColor() -> UIColor {
        return UIColor.init(red: 66/255, green: 165/255, blue: 245/255, alpha: 0.2)
    }
    
    static func spycodesBlueColor() -> UIColor {
        return UIColor.init(red: 66/255, green: 165/255, blue: 245/255, alpha: 1.0)
    }
    
    static func spycodesLightOrangeColor() -> UIColor {
        return UIColor.init(red: 255/255, green: 202/255, blue: 40/255, alpha: 0.2)
    }
    
    static func spycodesBlackColor() -> UIColor {
        return UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.2)
    }
    
    static func colorForTeam(team: Team) -> UIColor {
        if team == Team.Red {
            return UIColor.spycodesLightRedColor()
        }
        else if team == Team.Blue {
            return UIColor.spycodesLightBlueColor()
        }
        else if team == Team.Neutral {
            return UIColor.spycodesLightOrangeColor()
        } else {
            return UIColor.spycodesBlackColor()
        }
    }
}