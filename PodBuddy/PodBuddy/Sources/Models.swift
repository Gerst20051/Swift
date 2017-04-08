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

class PodcastFeedResult: Mappable {
    var title: String?
    var image: String?
    var author: String?
    var episodes: [PodcastFeedEpisode]?

    required init?(map: Map) {}

    func mapping(map: Map) {
        title <- map["title"]
        image <- map["image"]
        author <- map["author"]
        episodes <- map["episodes"]
    }
}

class PodcastFeedEpisode: Mappable {
    var id: String?
    var title: String?
    var date: String?
    var subtitle: String?
    var duration: String?
    var url: String?

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        date <- map["date"]
        subtitle <- map["subtitle"]
        duration <- map["duration"]
        url <- map["url"]
    }
}
