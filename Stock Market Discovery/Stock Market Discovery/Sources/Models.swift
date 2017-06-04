import ObjectMapper
import RealmSwift

class StockTicker: Object {
    dynamic var symbol = ""
    dynamic var name = ""
    dynamic var lastSalePrice = ""
    dynamic var marketCap = ""
    dynamic var ipoYear = ""
    dynamic var sector = ""
    dynamic var industry = ""
    dynamic var exchange = ""
    dynamic var starred = false

    override static func primaryKey() -> String? {
        return "symbol"
    }

    func toggleStarred() {
        let realm = try! Realm()
        try! realm.write {
            starred = !starred
        }
    }
}

class StockHistoryResult: Mappable {
    var date: String?
    var open: Float?
    var high: Float?
    var low: Float?
    var close: Float?
    var volume: Int?

    required init?(map: Map) {}

    func mapping(map: Map) {
        date <- map["date"]
        open <- map["open"]
        high <- map["high"]
        low <- map["low"]
        close <- map["close"]
        volume <- map["volume"]
    }
}
