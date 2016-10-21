import ObjectMapper

class GitlabProjectResult: Mappable {
    var id: Int?
    var name: String?

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
}
