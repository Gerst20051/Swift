import RealmSwift

class Portfolio: Object {

    dynamic var id = 0
    dynamic var name = ""
    internal var stocks = List<Stock>()

    override static func primaryKey() -> String? {
        return "id"
    }

}

class Stock: Object {

    dynamic var id = 0
    dynamic var name = ""

    override static func primaryKey() -> String? {
        return "id"
    }

}
