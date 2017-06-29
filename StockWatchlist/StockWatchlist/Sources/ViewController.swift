import Material
import RealmSwift
import SnapKit
import UIKit
import ZAlertView

class ViewController: BaseViewController {

    fileprivate var toolbar: Toolbar!
    fileprivate var toolbarBackButton: IconButton!
    fileprivate var toolbarAddButton: IconButton!
    fileprivate var toolbarShareButton: IconButton!
    let realm = try! Realm()
    let tableView = UITableView()
    let portfolioController = PortfolioController()
    var portfolios: Results<Portfolio> {
        return realm.objects(Portfolio.self).sorted(by: [ "name" ])
    }
    var selectedPortfolio: Portfolio?
    var selectedPortfolioStocks: [Stock] {
        return selectedPortfolio?.stocks.sorted { $0.name < $1.name } ?? []
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        RealmUtils.logDebugInfo()
        ZAlertView.neutralColor = AppColor.base
        setupInterface()
    }

    func setupInterface() {
        view.backgroundColor = .white
        createToolbar()
        createTableView()
        addContraintsToViews()
    }

    func addContraintsToViews() {
        addToolbarConstraints()
        addTableViewContraints()
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func addTableViewContraints() {
        tableView.snp.remakeConstraints { make -> Void in
            make.bottom.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.top.equalTo(toolbar.snp.bottom)
        }
    }

    func createTableView() {
        tableView.backgroundColor = Color.clear
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView(frame: .zero)
        view.addSubview(tableView)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let dialog = Dialog(type: .confirmation)
            dialog.alertTitle = "Confirm Delete"
            dialog.message = "Are you sure you want to delete this?"
            dialog.okHandler = { alert in
                if self.selectedPortfolio == nil {
                    self.portfolioController.deletePortfolio(self.portfolios[indexPath.row])
                } else {
                    self.portfolioController.deleteStock(self.selectedPortfolioStocks[indexPath.row])
                }
                tableView.reloadData()
                alert.dismissAlertView()
            }
            dialog.show()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getNumberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "cell") as? CustomTableViewCell) ?? CustomTableViewCell.init(style: .default, reuseIdentifier: "cell")
        cell.simpleLabel.text = getTextForRow(indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedPortfolio == nil {
            selectedPortfolio = portfolios[indexPath.row]
            tableView.reloadData()
            showToolbarBackButton()
            showToolbarShareButton()
            setToolbarTitle()
        } else {
            let ticker = selectedPortfolioStocks[indexPath.row].name
            let dialog = Dialog(type: .multipleChoice)
            dialog.addButton("Open Finviz") { alert in
                Utils.openUrl("https://finviz.com/quote.ashx?t=\(ticker)&ty=c&ta=0&p=d")
            }
            dialog.addButton("Open Twitter") { alert in
                let query = "$\(ticker)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                if let twitterDeepLinkUrl = URL(string: "twitter://search?query=\(query)"), UIApplication.shared.canOpenURL(twitterDeepLinkUrl) {
                    Utils.openUrl(twitterDeepLinkUrl)
                } else {
                    Utils.openUrl("https://mobile.twitter.com/search/live?q=\(query)")
                }
            }
            dialog.show()
        }
    }

    func getNumberOfRows() -> Int {
        guard selectedPortfolio == nil else {
            return selectedPortfolioStocks.count
        }
        return portfolios.count
    }

    func getTextForRow(_ row: Int) -> String {
        guard selectedPortfolio == nil else {
            return selectedPortfolioStocks[row].name
        }
        return portfolios[row].name
    }

}

extension ViewController {

    func addToolbarConstraints() {
        toolbar.snp.remakeConstraints { make -> Void in
            make.bottom.equalTo(tableView.snp.top)
            make.height.equalTo(50.0)
            make.top.width.equalTo(view)
        }
    }

    func createToolbar() {
        createToolbarButtons()
        toolbar = Toolbar()
        toolbar.backgroundColor = AppColor.base
        toolbar.detailLabel.textColor = Color.white
        toolbar.titleLabel.textColor = Color.white
        toolbar.rightViews = [ toolbarAddButton ]
        setToolbarTitle()
        view.addSubview(toolbar)
    }

    func createToolbarButtons() {
        toolbarBackButton = createToolbarBackButton()
        toolbarAddButton = createToolbarAddButton()
        toolbarShareButton = createToolbarShareButton()
    }

    func createToolbarBackButton() -> IconButton {
        let backImage = Icon.cm.arrowBack
        let backButton = IconButton()
        backButton.pulseColor = Color.white
        backButton.tintColor = Color.white
        backButton.setImage(backImage, for: .normal)
        backButton.setImage(backImage, for: .highlighted)
        backButton.addTarget(self, action: #selector(handleToolbarBackButtonPressed), for: .touchUpInside)
        return backButton
    }

    func createToolbarAddButton() -> IconButton {
        let addImage = Icon.cm.add
        let addButton = IconButton()
        addButton.pulseColor = Color.white
        addButton.tintColor = Color.white
        addButton.setImage(addImage, for: .normal)
        addButton.setImage(addImage, for: .highlighted)
        addButton.addTarget(self, action: #selector(handleToolbarAddButtonPressed), for: .touchUpInside)
        return addButton
    }

    func createToolbarShareButton() -> IconButton {
        let addImage = Icon.cm.share
        let addButton = IconButton()
        addButton.pulseColor = Color.white
        addButton.tintColor = Color.white
        addButton.setImage(addImage, for: .normal)
        addButton.setImage(addImage, for: .highlighted)
        addButton.addTarget(self, action: #selector(handleToolbarShareButtonPressed), for: .touchUpInside)
        return addButton
    }

    func showToolbarBackButton() {
        toolbar.leftViews = [ toolbarBackButton ]
    }

    func hideToolbarBackButton() {
        toolbar.leftViews = []
    }

    func showToolbarShareButton() {
        toolbar.rightViews = [ toolbarShareButton, toolbarAddButton ]
    }

    func hideToolbarShareButton() {
        toolbar.rightViews = [ toolbarAddButton ]
    }

    func handleToolbarBackButtonPressed() {
        selectedPortfolio = nil
        setToolbarTitle()
        hideToolbarBackButton()
        hideToolbarShareButton()
        tableView.reloadData()
    }

    func handleToolbarAddButtonPressed() {
        let dialog = Dialog(type: .confirmation)
        dialog.addTextField("name", placeHolder: selectedPortfolio == nil ? "Enter Name" : "Enter Ticker")
        dialog.alertTitle = selectedPortfolio == nil ? "Create Portfolio" : "Add Stock"
        dialog.allowTouchOutsideToDismiss = false
        dialog.okHandler = { alert in
            if let name = alert.getTextFieldWithIdentifier("name")!.text, !name.isEmpty {
                if self.selectedPortfolio == nil {
                    let portfolio = Portfolio()
                    portfolio.id = (self.realm.objects(Portfolio.self).sorted(byKeyPath: "id", ascending: false).first?.id ?? -1) + 1
                    portfolio.name = name
                    self.portfolioController.addPortfolio(portfolio)
                } else {
                    let stock = Stock()
                    stock.id = (self.realm.objects(Stock.self).sorted(byKeyPath: "id", ascending: false).first?.id ?? -1) + 1
                    stock.name = name.uppercased()
                    self.portfolioController.addStock(stock, to: self.selectedPortfolio!)
                }
                self.tableView.reloadData()
                alert.dismissAlertView()
            }
        }
        dialog.show()
    }

    func handleToolbarShareButtonPressed() {
        let dialog = Dialog(type: .multipleChoice)
        dialog.alertTitle = "Share"
        dialog.addButton("Open Finviz") { alert in
            Utils.openUrl("https://finviz.com/screener.ashx?v=211&t=\(self.getStockListForUrl())&ta=0&o=change")
        }
        dialog.addButton("Open Twitter") { alert in
            let query = self.getStockQueryForTwitter().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            if let twitterDeepLinkUrl = URL(string: "twitter://search?query=\(query)"), UIApplication.shared.canOpenURL(twitterDeepLinkUrl) {
                Utils.openUrl(twitterDeepLinkUrl)
            } else {
                Utils.openUrl("https://mobile.twitter.com/search/live?q=\(query)")
            }
        }
        dialog.addButton("Copy Finviz Url") { alert in
            UIPasteboard.general.string = "https://finviz.com/screener.ashx?v=211&t=\(self.getStockListForUrl())&ta=0&o=change"
        }
        dialog.addButton("Copy Twitter Search") { alert in
            UIPasteboard.general.string = self.getStockQueryForTwitter()
        }
        dialog.show()
    }

    func getStockListForUrl() -> String {
        return (selectedPortfolioStocks.reduce([]) { (accumulation: [String], nextValue: Stock) -> [String] in
            var accumulation = accumulation
            accumulation.append(nextValue.name)
            return accumulation
        }).joined(separator: ",")
    }

    func getStockQueryForTwitter() -> String {
        return (selectedPortfolioStocks.reduce([]) { (accumulation: [String], nextValue: Stock) -> [String] in
            var accumulation = accumulation
            accumulation.append("\"$\(nextValue.name)\"")
            return accumulation
        }).joined(separator: " OR ")
    }

    func setToolbarTitle() {
        if selectedPortfolio == nil {
            toolbar.title = "Stock Portfolios"
        } else {
            toolbar.title = selectedPortfolio!.name
        }
    }

}
