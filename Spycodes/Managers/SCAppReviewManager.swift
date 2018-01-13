import StoreKit

class SCAppReviewManager {
    static var reviewRequestedForSession = false

    static func requestReviewIfAllowed() {
        if reviewRequestedForSession {
            return
        }

        if let appOpens = SCUsageStatisticsManager.instance.getDiscreteUsageStatisticsValue(type: .appOpens) {
            switch appOpens {
            case 5, 10:
                SCAppReviewManager.requestReview()
            case _ where appOpens > 0 && appOpens % 25 == 0:
                SCAppReviewManager.requestReview()
            default:
                break
            }
        }
    }

    fileprivate static func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
            SCAppReviewManager.reviewRequestedForSession = true
        }
    }
}
