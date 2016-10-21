import Alamofire
import AlamofireObjectMapper
import Foundation
import PromiseKit

class CloudUtils {

    class func getYouTubeApiUrl(_ query: String, shouldFilter: Bool = false) -> String? {
        if let query = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed), let fields = "items/id/videoId".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            let results = 1, key = "AIzaSyBSXDaYvJGY4dbLFDF66NrSrlUYH9rVZ9A", filter = shouldFilter ? "&videoEmbeddable=true&videoSyndicated=true" : ""
            return "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=\(results)&q=\(query)&type=video\(filter)&fields=\(fields)&key=\(key)"
        }
        return nil
    }

}

class Cloud {

    class func downloadPlaylistVersion() -> Promise<Int> {
        let versionUrl = "https://gist.githubusercontent.com/Gerst20051/d8ff84358883664c5c07f0748fedbef4/raw/version.txt"
        return Promise { fulfill, reject in
            Alamofire.request(versionUrl, method: .get).validate().responseString { response in
                if response.result.isSuccess {
                    if let resultString = response.result.value, let playlistVersion = Int(resultString) {
                        fulfill(playlistVersion)
                    } else {
                        reject(PromiseError.invalidPlaylistVersion())
                    }
                } else {
                    reject(PromiseError.apiFailure(response.result.error))
                }
            }
        }
    }

    class func downloadPlaylistJSON() -> Promise<[Playlist]> {
        let playlistUrl = "https://gist.githubusercontent.com/Gerst20051/d8ff84358883664c5c07f0748fedbef4/raw/playlists.json"
        return Promise<[Playlist]> { fulfill, reject in
            Alamofire.request(playlistUrl, method: .get).validate().responseArray { (response: DataResponse<[Playlist]>) in
                if response.result.isSuccess {
                    if let playlists = response.result.value {
                        fulfill(playlists)
                    } else {
                        reject(PromiseError.invalidPlaylist())
                    }
                } else {
                    reject(PromiseError.apiFailure(response.result.error))
                }
            }
        }
    }

    class func getYouTubeVideo(_ url: String) -> Promise<String> {
        return Promise<String> { fulfill, reject in
            Alamofire.request(url, method: .get).responseObject { (response: DataResponse<YouTubeVideoSearchResults>) in
                if response.result.isSuccess {
                    if let results = response.result.value, let result = results.items?.first, let videoId = result.id?.videoId {
                        fulfill(videoId)
                    } else {
                        reject(PromiseError.noYouTubeSearchResults())
                    }
                } else {
                    reject(PromiseError.apiFailure(response.result.error))
                }
            }.responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }
        }
    }

}
