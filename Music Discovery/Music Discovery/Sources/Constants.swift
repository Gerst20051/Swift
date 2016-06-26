import UIKit

struct AppColor {
    static let AppIconRed = UIColor(red: 216.0 / 255.0, green: 53.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0)
}

struct UserDefaultsKey {
    static let PlaylistVersion = "playlist_version"
}

enum PromiseError: ErrorType {
    case ApiFailure(ErrorType?)
    case InvalidPlaylist()
    case InvalidPlaylistVersion()
    case NoYouTubeSearchResults()
}
