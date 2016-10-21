import ObjectMapper
import RealmSwift

open class StringObject: Object {
    open dynamic var value: String?
    dynamic var favorite = false

    convenience init(_ string: String) {
        self.init()
        value = string
    }
}

class Playlist: Object, Mappable {
    dynamic var name: String = ""
    dynamic var favorite = false
    dynamic var itemCount: Int = 0
    internal let items = List<StringObject>()

    required convenience init?(map: Map) {
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

    func addItem(_ string: String) {
        items.append(StringObject(string))
        itemCount += 1
    }
}

class YouTubeVideoSearchResults: Mappable {
    var items: [YouTubeVideoSearchResult]?

    required init?(map: Map) {}

    func mapping(map: Map) {
        items <- map["items"]
    }
}

class YouTubeVideoSearchResult: Mappable {
    var id: YouTubeVideoSearchResultId?

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
    }
}

class YouTubeVideoSearchResultId: Mappable {
    var videoId: String?

    required init?(map: Map) {}

    func mapping(map: Map) {
        videoId <- map["videoId"]
    }
}
