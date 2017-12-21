import UIKit

class SCOnboardingFlowEntry {
    fileprivate var displayImage: UIImage?
    fileprivate var displayText: String?

    init(_ mapping: [String: String]) {
        if let displayImage = mapping[SCConstants.onboardingFlowEntryKey.displayImageName.rawValue] {
            self.displayImage = UIImage(named: displayImage)
        }

        if let displayText = mapping[SCConstants.onboardingFlowEntryKey.displayText.rawValue] {
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
