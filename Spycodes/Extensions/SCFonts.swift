import UIKit

class SCFonts {
    // MARK: Font Types
    enum FontType: String {
        case Regular = "HelveticaNeue-Thin"
        case Medium = "HelveticaNeue-Medium"
        case Bold = "HelveticaNeue-Bold"
        case Other = "HelveticaNeue-Light"
    }

    // MARK: Font Sizes
    private static let largeFontSize: CGFloat = 36
    private static let intermediateFontSize: CGFloat = 24
    private static let regularFontSize: CGFloat = 20
    private static let smallFontSize: CGFloat = 16

    static func largeSizeFont(type: SCFonts.FontType) -> UIFont? {
        return UIFont(name: type.rawValue, size: SCFonts.largeFontSize)
    }

    static func intermediateSizeFont(type: SCFonts.FontType) -> UIFont? {
        return UIFont(name: type.rawValue, size: SCFonts.intermediateFontSize)
    }

    static func regularSizeFont(type: SCFonts.FontType) -> UIFont? {
        return UIFont(name: type.rawValue, size: SCFonts.regularFontSize)
    }

    static func smallSizeFont(type: SCFonts.FontType) -> UIFont? {
        return UIFont(name: type.rawValue, size: SCFonts.smallFontSize)
    }
}
