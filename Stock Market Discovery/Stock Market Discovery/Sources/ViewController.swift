import CSV
import Material
import RealmSwift
import SnapKit
import SwiftyUserDefaults
import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let realm = try! Realm()
    let tableView = UITableView()
    let stockTickersController = StockTickersController()
    var tickers: Results<StockTicker> {
        return realm.objects(StockTicker.self).sorted(byProperty: "symbol")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        RealmUtils.logDebugInfo()
        setupInterface()
    }

    func setupInterface() {
        view.backgroundColor = .white
        createTableView()
        addContraintsToViews()
        if shouldDownloadStockTickerList() {
            loadListOfStockTickers()
        }
    }

    func shouldDownloadStockTickerList() -> Bool {
        if let downloadDate = Defaults[.StockTickerDownloadDate] {
            return tickers.count == 0 || Date() >= Calendar.current.date(byAdding: .day, value: 30, to: downloadDate)!
        }
        return true
    }

    func loadListOfStockTickers() {
        Defaults[.StockTickerDownloadDate] = Date()
        for exchange in [ "NASDAQ", "NYSE" ] {
            let contents = try! String(contentsOf: URL(string: CloudUtils.getStockTickerUrlForExchange(exchange: exchange))!)
            parseStockTickerResults(exchange: exchange, contents: contents)
        }
    }

    func parseStockTickerResults(exchange: String, contents: String) {
        var tickers = [StockTicker]()
        let csv = try! CSV(string: contents, hasHeaderRow: true)
        for row in csv {
            let ticker = StockTicker()
            ticker.symbol = row[0]
            ticker.name = row[1]
            ticker.lastSalePrice = row[2]
            ticker.marketCap = row[3]
            ticker.ipoYear = row[5]
            ticker.sector = row[6]
            ticker.industry = row[7]
            ticker.exchange = exchange
            tickers.append(ticker)
        }
        stockTickersController.addStockTickers(tickers)
    }

    func addContraintsToViews() {
        addTableViewContraints()
    }

    func addTableViewContraints() {
        tableView.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.top.equalTo(view).offset(20.0)
        }
    }

    func createTableView() {
        tableView.backgroundColor = Color.clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        view.addSubview(tableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = (indexPath as NSIndexPath).row
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.backgroundColor = Color.clear
        cell.removeMargins()
        cell.textLabel?.text = tickers[row].symbol
        cell.textLabel?.textColor = Color.darkText.secondary
        return cell
    }

}
