import Alamofire
import AlamofireObjectMapper
import PromiseKit

class Cloud {

    class func downloadPlaylistVersion() -> Promise<Int> {
        let versionUrl = "https://gist.githubusercontent.com/Gerst20051/d8ff84358883664c5c07f0748fedbef4/raw/version.txt"
        return Promise { fulfill, reject in
            Alamofire.request(.GET, versionUrl).validate().responseString { response in
                if response.result.isSuccess {
                    // if let resultString = response.result.value, playlistVersion = Int(resultString) {
                    //     fulfill(playlistVersion)
                    // } else {
                    //     reject(PromiseError.InvalidPlaylistVersion())
                    // }
                } else {
                    // reject(PromiseError.ApiFailure(response.result.error))
                }
            }
        }
    }

}
