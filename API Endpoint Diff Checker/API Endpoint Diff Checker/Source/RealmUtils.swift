import RealmSwift

class Diff : Object {
    dynamic var id = 0
    dynamic var name = ""
    dynamic var created = NSDate()
    dynamic var deleted: NSDate? = nil

    override static func primaryKey() -> String? {
        return "id"
    }
}

class RealmUtils {

    class func logDebugInfo() {
        let realm = try! Realm()
        print("realm => \(realm)")
        print("realm path => \(realm.path)")
    }

    class func deleteAllData() {
        let realm = try! Realm()
        try! realm.write {
          realm.deleteAll()
        }
    }

}
