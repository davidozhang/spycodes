import UIKit

extension UIColor {
    static func spycodesRedColor() -> UIColor {
        return UIColor(red: 255/255, green: 83/255, blue: 77/255, alpha: 0.8)
    }

    static func spycodesBlueColor() -> UIColor {
        return UIColor(red: 0/255, green: 118/255, blue: 194/255, alpha: 0.8)
    }

    static func spycodesBlackColor() -> UIColor {
        return UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
    }

    static func spycodesGreenColor() -> UIColor {
        return UIColor(red: 0, green: 213/255, blue: 109/255, alpha: 0.8)
    }

    static func spycodesDarkGreenColor() -> UIColor {
        return UIColor(red: 0, green: 146/255, blue: 76/255, alpha: 1.0)
    }

    static func spycodesLightGrayColor() -> UIColor {
        return UIColor(red: 110/255, green: 110/255, blue: 110/255, alpha: 0.3)
    }

    static func spycodesGrayColor() -> UIColor {
        // Base color that works for both day/night modes
        return UIColor(red: 110/255, green: 110/255, blue: 110/255, alpha: 1.0)
    }

    static func nightModeBackgroundColor() -> UIColor {
        return UIColor(red: 55/255, green: 50/255, blue: 55/255, alpha: 0.6)
    }

    static func spycodesBorderColor() -> UIColor {
        return UIColor(red: 110/255, green: 110/255, blue: 110/255, alpha: 0.1)
    }

    static func dimBackgroundColor() -> UIColor {
        return UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
    }

    static func darkTintColor() -> UIColor {
        return UIColor(red: 170/255, green: 140/255, blue: 170/255, alpha: 0.2)
    }

    static func lightTintColor() -> UIColor {
        return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3)
    }

    static func colorForTeam(_ team: Team) -> UIColor {
        switch team {
        case .red:
            return .spycodesRedColor()
        case .blue:
            return .spycodesBlueColor()
        case .neutral:
            return .white
        default:
            return .spycodesBlackColor()
        }
    }
}
