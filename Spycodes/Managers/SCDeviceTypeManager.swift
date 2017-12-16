import UIKit

class SCDeviceTypeManager {
    enum DeviceType: String {
        case iPhone_4 = "iPhone_4"
        case iPhone_5 = "iPhone_5"
        case iPhone_6_7_8 = "iPhone_6_7_8"
        case iPhone_6_7_8_Plus = "iPhone_6_7_8_Plus"
        case iPhone_X = "iPhone_X"
        case iPad = "iPad"
        case Unknown = "Unknown"
    }

    static func getDeviceType() -> DeviceType {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 960:
                return DeviceType.iPhone_4
            case 1136:
                return DeviceType.iPhone_5
            case 1334:
                return DeviceType.iPhone_6_7_8
            case 1920, 2208:
                return DeviceType.iPhone_6_7_8_Plus
            case 2436:
                return DeviceType.iPhone_X
            default:
                return DeviceType.Unknown
            }
        }

        return DeviceType.iPad
    }
}
