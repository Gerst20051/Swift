import ObjectMapper
import RealmSwift

public class StringObject: Object {
    public dynamic var value: String?
}

class Playlist: Object, Mappable {
    dynamic var name: String = ""
    internal let items = List<StringObject>()

    required convenience init?(_ map: Map) {
        self.init()
    }

    override class func primaryKey() -> String? {
        return "name"
    }

    func mapping(map: Map) {
        name <- map["name"]
        var items: [String]? = nil
        items <- map["items"]
        items?.forEach { option in
            let value = StringObject()
            value.value = option
            self.items.append(value)
        }
    }
}
