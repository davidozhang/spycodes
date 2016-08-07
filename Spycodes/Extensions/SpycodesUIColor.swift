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
    
    static func spycodesBlackColor() -> UIColor {
        return UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
    }
    
    static func colorForTeam(team: Team) -> UIColor {
        if team == Team.Red {
            return UIColor.spycodesLightRedColor()
        }
        else if team == Team.Blue {
            return UIColor.spycodesLightBlueColor()
        }
        else {
            return UIColor.spycodesBlackColor()
        }
    }
}