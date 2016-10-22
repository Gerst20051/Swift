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
}
