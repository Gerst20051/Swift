import RealmSwift

class Diff : Object {
    dynamic var id = 0
    dynamic var name = ""
    // type
    // url1
    // url2
    // file1
    // file2
    // saveddiffs [SavedDiff]
    dynamic var created = NSDate()
    dynamic var deleted: NSDate? = nil

    override static func primaryKey() -> String? {
        return "id"
    }
}

class SavedDiff : Object {
    dynamic var id = 0
    dynamic var name = ""
    // is_public
    // public_link
    // previous_file
    // current_file
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
        print("realm path => \(realm.configuration.fileURL!.absoluteString)")
    }

    class func deleteAllData() {
        let realm = try! Realm()
        try! realm.write {
          realm.deleteAll()
        }
    }

}
