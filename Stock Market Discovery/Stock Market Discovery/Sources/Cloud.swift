import Alamofire
import AlamofireObjectMapper
import PromiseKit

class CloudUtils {

    static let basedomain = "hnswave.co"
    static let baseurl = "http://\(basedomain):8001"

    class func getStockTickerUrlForExchange(exchange: String) -> String {
        return "http://www.nasdaq.com/screening/companies-by-industry.aspx?exchange=\(exchange)&render=download"
    }

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

    class func getStockHistory(ticker: String) -> Promise<[StockHistoryResult]> {
        return Promise { fulfill, reject in
            _ = Networking.manager.request("\(CloudUtils.baseurl)/stockhistory/\(ticker)", method: .get).validate().responseArray { (response: DataResponse<[StockHistoryResult]>) in
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
