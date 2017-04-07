import Foundation

class SCVersionManager {
    // MARK: Public
    static func checkLatestAppVersion(_ failure: @escaping ((Void) -> Void)) {
        let successHandler: (NSDictionary) -> Void = { dict in
            if let resultCount = dict["resultCount"] as? NSInteger, resultCount == 1,
               let result = dict["results"] as? NSArray,
               let dict = result[0] as? NSDictionary,
               let latestAppVersion = dict["version"] as? String,
               let currentAppVersion = Bundle.main.object(
                   forInfoDictionaryKey: "CFBundleShortVersionString"
               ) as? String {
                if let current = Double(currentAppVersion),
                   let latest = Double(latestAppVersion), current < latest {
                    failure()
                }
            }
        }

        SCVersionManager.sendRequest(successHandler)
    }

    // MARK: Private
    fileprivate static func sendRequest(_ success: @escaping ((NSDictionary) -> Void)) {
        let requestURL = URL(string: SCConstants.versionURL)
        let task = URLSession(
            configuration: URLSessionConfiguration.default).dataTask(
                with: requestURL!, completionHandler: { (data, response, error) in
            if let data = data,
               let response = response as? HTTPURLResponse,
               let dictionary = SCVersionManager.deserialize(data) {
                if response.statusCode == 200 {
                    success(dictionary)
                }
            }
        }
            ) 

        task.resume()
    }

    fileprivate static func deserialize(_ data: Data?) -> NSDictionary? {
        guard let data = data else { return nil }

        if let result = NSString(data: data, encoding: String.Encoding.ascii.rawValue),
           let data = result.data(using: String.Encoding.utf8.rawValue) {
            do {
                if let dictionary = try JSONSerialization.jsonObject(
                    with: data, options: []
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
