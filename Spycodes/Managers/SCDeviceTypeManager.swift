import UIKit

class SCDeviceTypeManager {
    static func getDeviceType() -> SCDeviceType {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 960:
                return SCDeviceType.iPhone_4
            case 1136:
                return SCDeviceType.iPhone_5
            case 1334:
                return SCDeviceType.iPhone_6_7_8
            case 1920, 2208:
                return SCDeviceType.iPhone_6_7_8_Plus
            case 2436:
                return SCDeviceType.iPhone_X
            default:
                return SCDeviceType.Unknown
            }
        }

        return SCDeviceType.iPad
    }
}
