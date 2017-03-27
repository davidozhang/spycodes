import Foundation

class SCVersionManager {
    // MARK: Public
    static func checkLatestAppVersion(failure: ((Void) -> Void)) {
        let successHandler: (NSDictionary) -> Void = { dict in
            if let resultCount = dict["resultCount"] as? NSInteger where resultCount == 1,
               let latestAppVersion = dict["results"]?[0]?["version"] as? String,
               let currentAppVersion = NSBundle.mainBundle().objectForInfoDictionaryKey(
                   "CFBundleShortVersionString"
               ) as? String {
                if let current = Double(currentAppVersion),
                       latest = Double(latestAppVersion) where current < latest {
                    failure()
                }
            }
        }

        SCVersionManager.sendRequest(successHandler)
    }

    // MARK: Private
    private static func sendRequest(success: ((NSDictionary) -> Void)) {
        let requestURL = NSURL(string: SCConstants.versionURL)
        let task = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration()).dataTaskWithURL(
                requestURL!
            ) { (data, response, error) in
            if let data = data,
                   response = response as? NSHTTPURLResponse,
                   dictionary = SCVersionManager.deserialize(data) {
                if response.statusCode == 200 {
                    success(dictionary)
                }
            }
        }

        task.resume()
    }

    private static func deserialize(data: NSData?) -> NSDictionary? {
        guard let data = data else { return nil }

        if let result = NSString(data: data, encoding: NSASCIIStringEncoding),
               data = result.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                if let dictionary = try NSJSONSerialization.JSONObjectWithData(
                    data, options: []
                ) as? NSDictionary {
                    return dictionary
                }
            } catch {
                print("Cannot deserialize version data to dictionary")
            }
        }

        return nil
    }
}
