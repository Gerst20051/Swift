import ObjectMapper
import RealmSwift

public class StringObject: Object {
    public dynamic var value: String?

    convenience init(_ string: String) {
        self.init()
        value = string
    }
}

class Playlist: Object, Mappable {
    dynamic var name: String = ""
    dynamic var itemCount: Int = 0
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
        items?.forEach(addItem)
    }

    func addItem(string: String) {
        items.append(StringObject(string))
        itemCount += 1
    }
}
