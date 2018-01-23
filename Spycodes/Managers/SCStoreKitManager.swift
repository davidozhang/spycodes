import StoreKit

class SCStoreKitManager {
    static var reviewRequestedForSession = false

    static func requestReviewIfAllowed() {
        if reviewRequestedForSession {
            return
        }

        if let appOpens = SCUsageStatisticsManager.instance.getDiscreteUsageStatisticsValue(type: .appOpens) {
            switch appOpens {
            case 5, 10:
                SCStoreKitManager.requestReview()
            case _ where appOpens > 0 && appOpens % 25 == 0:
                SCStoreKitManager.requestReview()
            default:
                break
            }
        }

        // TODO: Figure out how to incorporate game plays into determining when to request reviews
    }

    fileprivate static func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
            SCStoreKitManager.reviewRequestedForSession = true
        }
    }
}
