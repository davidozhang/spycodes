import UIKit
import SwiftGifOrigin

class SCPageViewFlowEntry {
    fileprivate var displayImage: UIImage?
    fileprivate var displayImageType: DisplayImageType?
    fileprivate var displayText: String?
    
    enum DisplayImageType: Int {
        case GIF
        case Image
    }

    init(_ mapping: [String: Any]) {
        if let displayImageType = mapping[SCConstants.onboardingFlowEntryKey.displayImageType.rawValue] as? DisplayImageType {
            self.displayImageType = displayImageType
        }

        if let displayImageName = mapping[SCConstants.onboardingFlowEntryKey.displayImageName.rawValue] as? String {
            if let displayImageType = self.displayImageType {
                switch displayImageType {
                case .GIF:
                    self.displayImage = UIImage.gif(name: displayImageName)
                case .Image:
                    self.displayImage = UIImage(named: displayImageName)
                }
            }
        }

        if let displayText = mapping[SCConstants.onboardingFlowEntryKey.displayText.rawValue] as? String? {
            self.displayText = displayText
        }
    }
    
    func getDisplayImage() -> UIImage? {
        return self.displayImage
    }
    
    func getDisplayText() -> String? {
        return self.displayText
    }
}
