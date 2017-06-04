import RealmSwift

class StockTickersController {
    let realm: Realm!

    init(realm: Realm) {
        self.realm = realm
    }

    convenience init() {
        self.init(realm: try! Realm())
    }

    func clearStockTickers() {
        try! realm.write {
            realm.deleteAll()
        }
    }

    func addStockTickers(_ tickers: [StockTicker]) {
        try! realm.write {
            realm.add(tickers, update: true)
        }
    }

    func addStockTicker(_ ticker: StockTicker) {
        try! realm.write {
            realm.add(ticker, update: true)
        }
    }
}
