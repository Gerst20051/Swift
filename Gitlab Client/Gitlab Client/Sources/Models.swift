import ObjectMapper

class GitlabProjectResult: Mappable {
    var id: Int?
    var name: String?

    required init?(_ map: Map) {}

    func mapping(_ map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
}
