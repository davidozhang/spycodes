import UIKit
import SwiftGifOrigin

class SCPageViewFlowEntry {
    fileprivate var displayImage: UIImage?
    fileprivate var displayImageType: DisplayImageType?
    fileprivate var displayText: String?
    fileprivate var headerText: String?
    
    enum DisplayImageType: Int {
        case GIF
        case Image
    }

    init(_ mapping: [String: Any]) {
        if let displayImageType = mapping[SCConstants.pageViewFlowEntryKey.displayImageType.rawValue] as? DisplayImageType {
            self.displayImageType = displayImageType
        }

        if let displayImageName = mapping[SCConstants.pageViewFlowEntryKey.displayImageName.rawValue] as? String {
            if let displayImageType = self.displayImageType {
                switch displayImageType {
                case .GIF:
                    self.displayImage = UIImage.gif(name: displayImageName)
                case .Image:
                    self.displayImage = UIImage(named: displayImageName)
                }
            }
        }

        if let displayText = mapping[SCConstants.pageViewFlowEntryKey.displayText.rawValue] as? String? {
            self.displayText = displayText
        }

        if let headerText = mapping[SCConstants.pageViewFlowEntryKey.headerText.rawValue] as? String? {
            self.headerText = headerText
        }
    }
    
    func getDisplayImage() -> UIImage? {
        return self.displayImage
    }
    
    func getDisplayText() -> String? {
        return self.displayText
    }

    func getHeaderText() -> String? {
        return self.headerText
    }
}
