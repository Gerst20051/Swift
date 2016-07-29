import Alamofire
import AlamofireObjectMapper
import PromiseKit
import SwiftyUserDefaults

struct CloudEndpoints {

    static let Projects = "projects"

}

class CloudUtils {

    static let domain = "gitlab.pdev.io"

    class func getUrl(forEndpoint endpoint: String) -> String? {
        if let gitlabToken = Defaults[.GitlabToken], !gitlabToken.isEmpty {
            return "http://\(domain)/api/v3/\(endpoint)?private_token=\(gitlabToken)&per_page=100"
        }
        return nil
    }

}

class Networking {

    static let manager: Manager = {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            CloudUtils.domain: .disableEvaluation
        ]
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.Manager.defaultHTTPHeaders
        return Alamofire.Manager(configuration: configuration, serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
    }()

}

class Cloud {

    class func getProjectList() -> Promise<[GitlabProjectResult]> {
        return Promise { fulfill, reject in
            guard let url = CloudUtils.getUrl(forEndpoint: CloudEndpoints.Projects) else {
                reject(PromiseError.InvalidUrl())
                return
            }
            _ = Networking.manager.request(.GET, url).validate().responseArray { (response: Response<[GitlabProjectResult], NSError>) in
                if response.result.isSuccess {
                    if let projects = response.result.value {
                        fulfill(projects)
                    } else {
                        reject(PromiseError.InvalidProjects())
                    }
                } else {
                    reject(PromiseError.ApiFailure(response.result.error))
                }
            }
        }
    }

}
