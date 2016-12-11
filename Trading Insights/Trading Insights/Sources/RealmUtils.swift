import RealmSwift

class RealmUtils {

    class func logDebugInfo() {
        let realm = try! Realm()
        print("realm path => \(realm.configuration.fileURL!.absoluteString)")
    }

    class func deleteAllData() {
        let realm = try! Realm()
        try! realm.write {
          realm.deleteAll()
        }
    }

}
