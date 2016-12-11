import UIKit

extension UIColor {
    static func spycodesLightRedColor() -> UIColor {
        return UIColor.init(red: 233/255, green: 109/255, blue: 99/255, alpha: 0.3)
    }
    
    static func spycodesRedColor() -> UIColor {
        return UIColor.init(red: 233/255, green: 109/255, blue: 99/255, alpha: 1.0)
    }
    
    static func spycodesLightBlueColor() -> UIColor {
        return UIColor.init(red: 133/255, green: 193/255, blue: 245/255, alpha: 0.3)
    }
    
    static func spycodesBlueColor() -> UIColor {
        return UIColor.init(red: 133/255, green: 193/255, blue: 245/255, alpha: 1.0)
    }
    
    static func spycodesLightYellowColor() -> UIColor {
        return UIColor.init(red: 244/255, green: 186/255, blue: 112/255, alpha: 0.3)
    }
    
    static func spycodesBlackColor() -> UIColor {
        return UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
    }
    
    static func spycodesGreenColor() -> UIColor {
        return UIColor.init(red: 0, green: 213/255, blue: 109/255, alpha: 1.0)
    }
    
    static func spycodesDarkGreenColor() -> UIColor {
        return UIColor.init(red: 0, green: 146/255, blue: 76/255, alpha: 1.0)
    }
    
    static func colorForTeam(team: Team) -> UIColor {
        if team == Team.Red {
            return UIColor.spycodesLightRedColor()
        }
        else if team == Team.Blue {
            return UIColor.spycodesLightBlueColor()
        }
        else if team == Team.Neutral {
            return UIColor.spycodesLightYellowColor()
        } else {
            return UIColor.spycodesBlackColor()
        }
    }
}
