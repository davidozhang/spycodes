import UIKit

class SCFonts {
    // MARK: Font Types
    enum fontType: String {
        case cursive = "SnellRoundhand-Black"
        case light = "AppleSDGothicNeo-Light"
        case regular = "AppleSDGothicNeo-Regular"
        case medium = "AppleSDGothicNeo-Medium"
        case bold = "AppleSDGothicNeo-Bold"
    }

    // MARK: Font Sizes
    fileprivate static let largeFontSize: CGFloat = 36
    fileprivate static let intermediateFontSize: CGFloat = 24
    fileprivate static let regularFontSize: CGFloat = 20
    fileprivate static let smallFontSize: CGFloat = 16

    static func largeSizeFont(_ type: SCFonts.fontType) -> UIFont? {
        return UIFont(name: type.rawValue, size: SCFonts.largeFontSize)
    }

    static func intermediateSizeFont(_ type: SCFonts.fontType) -> UIFont? {
        return UIFont(name: type.rawValue, size: SCFonts.intermediateFontSize)
    }

    static func regularSizeFont(_ type: SCFonts.fontType) -> UIFont? {
        return UIFont(name: type.rawValue, size: SCFonts.regularFontSize)
    }

    static func smallSizeFont(_ type: SCFonts.fontType) -> UIFont? {
        return UIFont(name: type.rawValue, size: SCFonts.smallFontSize)
    }
}
