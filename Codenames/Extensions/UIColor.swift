import UIKit

extension UIColor {
    static func codenamesLightRedColor() -> UIColor {
        return UIColor.init(red: 239/255, green: 83/255, blue: 80/255, alpha: 0.2)
    }
    
    static func codenamesRedColor() -> UIColor {
        return UIColor.init(red: 239/255, green: 83/255, blue: 80/255, alpha: 1.0)
    }
    
    static func codenamesLightBlueColor() -> UIColor {
        return UIColor.init(red: 66/255, green: 165/255, blue: 245/255, alpha: 0.2)
    }
    
    static func codenamesBlueColor() -> UIColor {
        return UIColor.init(red: 66/255, green: 165/255, blue: 245/255, alpha: 1.0)
    }
    
    static func codenamesLightOrangeColor() -> UIColor {
        return UIColor.init(red: 255/255, green: 202/255, blue: 40/255, alpha: 0.2)
    }
    
    static func codenamesBlackColor() -> UIColor {
        return UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.2)
    }
    
    static func colorForTeam(team: Team) -> UIColor {
        if team == Team.Red {
            return UIColor.codenamesLightRedColor()
        }
        else if team == Team.Blue {
            return UIColor.codenamesLightBlueColor()
        }
        else if team == Team.Neutral {
            return UIColor.codenamesLightOrangeColor()
        } else {
            return UIColor.codenamesBlackColor()
        }
    }
}