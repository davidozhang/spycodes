import UIKit

extension UIColor {
    static func spycodesRedColor() -> UIColor {
        return UIColor(red: 255/255, green: 83/255, blue: 77/255, alpha: 0.8)
    }

    static func spycodesBlueColor() -> UIColor {
        return UIColor(red: 0/255, green: 118/255, blue: 194/255, alpha: 0.8)
    }

    static func spycodesBlackColor() -> UIColor {
        return UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    }

    static func spycodesGreenColor() -> UIColor {
        return UIColor(red: 0, green: 213/255, blue: 109/255, alpha: 0.8)
    }

    static func spycodesDarkGreenColor() -> UIColor {
        return UIColor(red: 0, green: 146/255, blue: 76/255, alpha: 1.0)
    }

    static func spycodesGrayColor() -> UIColor {
        // Base color that works for both day/night modes
        return UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
    }

    static func dimBackgroundColor() -> UIColor {
        return UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
    }

    static func colorForTeam(_ team: Team) -> UIColor {
        switch team {
        case .red:
            return UIColor.spycodesRedColor()
        case .blue:
            return UIColor.spycodesBlueColor()
        case .neutral:
            return UIColor.white
        default:
            return UIColor.spycodesBlackColor()
        }
    }
}
