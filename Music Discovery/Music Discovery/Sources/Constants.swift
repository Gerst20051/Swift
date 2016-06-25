
struct UserDefaultsKey {
    static let PlaylistVersion = "playlist_version"
}

enum PromiseError: ErrorType {
    case ApiFailure(ErrorType?)
    case InvalidPlaylist()
    case InvalidPlaylistVersion()
}
