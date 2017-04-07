import ObjectMapper
import RealmSwift

class PodcastSearchResult: Mappable {
    var title: String?
    var url: String?

    required init?(map: Map) {}

    func mapping(map: Map) {
        title <- map["title"]
        url <- map["url"]
    }
}
