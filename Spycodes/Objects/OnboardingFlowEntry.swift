import UIKit

class SCOnboardingFlowEntry {
    fileprivate var displayImage: UIImage?
    fileprivate var displayImageHeight: Int?
    fileprivate var displayImageWidth: Int?
    fileprivate var displayText: String?

    init(_ mapping: [String: Any]) {
        if let displayImageName = mapping[SCConstants.onboardingFlowEntryKey.displayImageName.rawValue] as? String {
            self.displayImage = UIImage(named: displayImageName)
        }

        if let displayText = mapping[SCConstants.onboardingFlowEntryKey.displayText.rawValue] as? String? {
            self.displayText = displayText
        }

        if let displayImageHeight = mapping[SCConstants.onboardingFlowEntryKey.displayImageHeight.rawValue] as? Int {
            self.displayImageHeight = displayImageHeight
        }
        
        if let displayImageWidth = mapping[SCConstants.onboardingFlowEntryKey.displayImageWidth.rawValue] as? Int {
            self.displayImageWidth = displayImageWidth
        }
    }
    
    func getDisplayImage() -> UIImage? {
        return self.displayImage
    }
    
    func getDisplayImageHeight() -> Int? {
        return self.displayImageHeight
    }
    
    func getDisplayImageWidth() -> Int? {
        return self.displayImageWidth
    }
    
    func getDisplayText() -> String? {
        return self.displayText
    }
}
