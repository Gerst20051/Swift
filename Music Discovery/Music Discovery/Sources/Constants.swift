import UIKit

struct AppColor {
    static let AppIconRed = UIColor(red: 216.0 / 255.0, green: 53.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0)
}

enum PromiseError: Error {
    case apiFailure(Error?)
    case invalidPlaylist()
    case invalidPlaylistVersion()
    case noYouTubeSearchResults()
}
