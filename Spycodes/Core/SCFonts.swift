import UIKit

class SCFonts {
    // MARK: Font Sizes
    fileprivate static let largeFontSize: CGFloat = 40
    fileprivate static let intermediateFontSize: CGFloat = 24
    fileprivate static let regularFontSize: CGFloat = 20
    fileprivate static let smallFontSize: CGFloat = 16

    static func largeSizeFont(_ type: SCFontType) -> UIFont? {
        return UIFont(name: type.rawValue, size: SCFonts.largeFontSize)
    }

    static func intermediateSizeFont(_ type: SCFontType) -> UIFont? {
        return UIFont(name: type.rawValue, size: SCFonts.intermediateFontSize)
    }

    static func regularSizeFont(_ type: SCFontType) -> UIFont? {
        return UIFont(name: type.rawValue, size: SCFonts.regularFontSize)
    }

    static func smallSizeFont(_ type: SCFontType) -> UIFont? {
        return UIFont(name: type.rawValue, size: SCFonts.smallFontSize)
    }
}
