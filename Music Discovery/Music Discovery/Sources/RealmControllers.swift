import RealmSwift

class PlaylistController {
    let realm: Realm!

    init(realm: Realm) {
        self.realm = realm
    }

    convenience init() {
        self.init(realm: try! Realm())
    }

    func clearPlaylists() {
        try! realm.write {
            realm.deleteAll()
        }
    }

    func addPlaylist(_ playlist: Playlist) {
        try! realm.write {
            realm.add(playlist, update: true)
        }
    }

    func toggleFavorite(_ playlist: Playlist) {
        try! realm.write {
            playlist.favorite = !playlist.favorite
        }
    }

    func toggleFavorite(_ playlistItem: StringObject) {
        try! realm.write {
            playlistItem.favorite = !playlistItem.favorite
        }
    }
}
