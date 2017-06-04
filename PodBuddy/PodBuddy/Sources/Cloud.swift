import Alamofire
import AlamofireObjectMapper
import PromiseKit

class CloudUtils {

    static let basedomain = "hnswave.co"
    static let baseurl = "http://\(basedomain):8003"

}

class Networking {

    static let manager: SessionManager = {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            CloudUtils.basedomain: .disableEvaluation
        ]
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        return SessionManager(configuration: configuration, serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
    }()

}

class Cloud {

    class func searchPodcasts(keywords: String) -> Promise<[PodcastSearchResult]> {
        return Promise { fulfill, reject in
            _ = Networking.manager.request("\(CloudUtils.baseurl)/search/\(keywords.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)", method: .get).validate().responseArray { (response: DataResponse<[PodcastSearchResult]>) in
                if response.result.isSuccess {
                    if let results = response.result.value {
                        fulfill(results)
                    } else {
                        reject(PromiseError.invalidResults())
                    }
                } else {
                    reject(PromiseError.apiFailure(response.result.error))
                }
            }
        }
    }

    class func retrievePodcastFeed(url: String) -> Promise<PodcastFeedResult> {
        return Promise { fulfill, reject in
            _ = Networking.manager.request("\(CloudUtils.baseurl)/feed/\(url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)", method: .get).validate().responseObject { (response: DataResponse<PodcastFeedResult>) in
                if response.result.isSuccess {
                    if let results = response.result.value {
                        fulfill(results)
                    } else {
                        reject(PromiseError.invalidResults())
                    }
                } else {
                    reject(PromiseError.apiFailure(response.result.error))
                }
            }
        }
    }

}
