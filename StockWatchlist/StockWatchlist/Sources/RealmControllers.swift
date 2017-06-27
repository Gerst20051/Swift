import RealmSwift

class PortfolioController {

    let realm: Realm!

    init(realm: Realm) {
        self.realm = realm
    }

    convenience init() {
        self.init(realm: try! Realm())
    }

    func addPortfolio(_ portfolio: Portfolio) {
        try! realm.write {
            realm.add(portfolio, update: true)
        }
    }

    func addStock(_ stock: Stock, to portfolio: Portfolio) {
        try! realm.write {
            portfolio.stocks.append(stock)
            realm.add(portfolio, update: true)
        }
    }

}
