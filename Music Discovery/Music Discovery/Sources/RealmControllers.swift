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

    func addPlaylist(playlist: Playlist) {
        try! realm.write {
            self.realm.add(playlist, update: true)
        }
    }
}
