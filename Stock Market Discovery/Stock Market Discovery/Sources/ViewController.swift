import CSV
import Material
import RealmSwift
import SnapKit
import SwiftyUserDefaults
import UIKit

class ViewController: BaseViewController {

    fileprivate var toolbar: Toolbar!
    fileprivate var bottomTabBar: BottomTabBar!
    fileprivate var searchBar: SearchBar!
    fileprivate var toolbarBackButton: IconButton!
    fileprivate var toolbarSettingsButton: IconButton!
    let realm = try! Realm()
    let tableView = UITableView()
    let stockTickersController = StockTickersController()
    var appName: String {
        return Bundle.main.infoDictionary!["CFBundleName"] as! String
    }
    var tickers: Results<StockTicker> {
        return realm.objects(StockTicker.self).sorted(byProperty: "symbol")
    }
    var sectorTickers: Results<StockTicker> {
        if searchMode && searchText.isNotEmpty {
            let industryTickers = realm.objects(StockTicker.self).filter(NSPredicate(format: "industry == %@", selectedSectorIndustry.isEmpty ? "n/a" : selectedSectorIndustry))
            var results = industryTickers.filter(NSPredicate(format: "symbol BEGINSWITH %@", searchText))
            if results.count.isEmpty {
                results = industryTickers.filter(NSPredicate(format: "name CONTAINS[c] %@", searchText))
            }
            return results.sorted(by: [ SortDescriptor(property: "starred", ascending: false), "symbol" ])
        }
        return realm.objects(StockTicker.self).filter(NSPredicate(format: "industry == %@", selectedSectorIndustry.isEmpty ? "n/a" : selectedSectorIndustry)).sorted(by: [ SortDescriptor(property: "starred", ascending: false), "symbol" ])
    }
    var starred: Results<StockTicker> {
        return realm.objects(StockTicker.self).filter("starred == 1").sorted(byProperty: "symbol")
    }
    var searchTickers: Results<StockTicker> {
        return realm.objects(StockTicker.self).filter(NSPredicate(format: "symbol BEGINSWITH %@", searchText)).sorted(by: [ SortDescriptor(property: "starred", ascending: false), "symbol" ])
    }
    var searchNames: Results<StockTicker> {
        return realm.objects(StockTicker.self).filter(NSPredicate(format: "name CONTAINS[c] %@", searchText)).sorted(by: [ SortDescriptor(property: "starred", ascending: false), "symbol" ])
    }
    var currentResults: Results<StockTicker>? // TODO: test caching results for optimal performance?
    var selectedSector: String = "" {
        didSet {
            if selectedSector.isEmpty {
                hideToolbarBackButton()
                distinctSectorIndustries = []
            } else {
                showToolbarBackButton()
                if selectedSector != "n/a" {
                    setDistinctSectorIndustries(forSector: selectedSector)
                }
            }
            setToolbarTitle()
            scrollTableViewToTop()
            tableView.reloadData()
        }
    }
    var selectedSectorIndustry: String = "" {
        didSet {
            setToolbarSubtitle()
            scrollTableViewToTop()
            tableView.reloadData()
        }
    }
    var starredMode: Bool = false {
        didSet {
            if starredMode {
                hideToolbarBackButton()
            } else if selectedSector.isNotEmpty {
                showToolbarBackButton()
            }
            setToolbarTitle()
            setToolbarSubtitle()
            tableView.reloadData()
        }
    }
    var searchMode: Bool = false {
        didSet {
            showToolbarOrSearchBar()
        }
    }
    var searchText = ""
    var distinctSectors = [String]()
    var distinctSectorIndustries = [String]()
    var previousSelectedTab: UITabBarItem?

    override func viewDidAppear(_ animated: Bool) {
        if let selectedTab = previousSelectedTab {
            bottomTabBar.selectedItem = selectedTab
            starredMode = selectedTab.title == "Watchlist"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        RealmUtils.logDebugInfo()
        setupInterface()
    }

    func setupInterface() {
        view.backgroundColor = .white
        createToolbar()
        createSearchBar()
        showToolbarOrSearchBar()
        createTableView()
        createTabBar()
        addContraintsToViews()
        if shouldDownloadStockTickerList() {
            loadListOfStockTickers()
        }
        setDistinctSectors()
    }

    func addContraintsToViews() {
        addToolbarOrSearchBarConstraints()
        addTableViewContraints()
        addTabBarContraints()
    }

}

extension ViewController {

    func shouldDownloadStockTickerList() -> Bool {
        if let downloadDate = Defaults[.StockTickerDownloadDate] {
            return tickers.count == 0 || Date() >= Calendar.current.date(byAdding: .day, value: 30, to: downloadDate)!
        }
        return true
    }

    func loadListOfStockTickers() {
        Defaults[.StockTickerDownloadDate] = Date()
        // TODO: Also Need To Download Forex And Other Instruments Like UWTI
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
            ticker.name = row[1].replacingOccurrences(of: "&#39;", with: "'").replacingOccurrences(of: "  ", with: " ")
            ticker.lastSalePrice = row[2]
            ticker.marketCap = row[3]
            ticker.ipoYear = row[5]
            ticker.sector = row[6]
            ticker.industry = cleanIndustryName(row[7])
            ticker.exchange = exchange
            tickers.append(ticker)
        }
        stockTickersController.addStockTickers(tickers)
        // TODO: Check To Make Sure Starred Tickers Stay Starred On Update
    }

    func cleanIndustryName(_ name: String) -> String {
        if name == "n/a" {
            return name
        }
        var name = name.capitalized
        name = name.replacingOccurrences(of: ":O.E.M.", with: ": O.E.M.")
        name = name.replacingOccurrences(of: "&", with: " & ")
        name = name.replacingOccurrences(of: "/", with: " / ")
        name = name.replacingOccurrences(of: "  ", with: " ")
        return name
    }

    func setDistinctSectors() {
        distinctSectors = Array(Set(realm.objects(StockTicker.self).value(forKey: "sector") as! [String])).sorted()
    }

    func setDistinctSectorIndustries(forSector sector: String) {
        let sector = sector == "Other" ? "n/a" : sector
        distinctSectorIndustries = Array(Set(realm.objects(StockTicker.self).filter(NSPredicate(format: "sector == %@", sector)).value(forKey: "industry") as! [String])).sorted()
    }

}

class GenericTableViewCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        applyGenericStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func applyGenericStyle() {
        backgroundColor = Color.clear
        removeMargins()
    }

}

class CustomTableViewCell: GenericTableViewCell {

    var isSimpleCell = true
    var stockTicker: StockTicker?
    let customView = UIView()
    let simpleLabel = UILabel()
    let complexTitleLabel = UILabel()
    let complexDetailLabel = UILabel()
    let complexImageView = UIImageView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        applyCustomStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func applyCustomStyle() {
        customView.removeFromSuperview()
        contentView.addSubview(customView)
        customView.snp.makeConstraints { make -> Void in
            make.center.equalTo(contentView)
            make.height.equalTo(contentView)
            make.width.equalTo(contentView)
        }
        if isSimpleCell {
            removeComplexCell()
            buildSimpleCell()
            simpleLabel.textColor = Color.darkText.secondary
        } else {
            removeSimpleCell()
            buildComplexCell()
            complexTitleLabel.textColor = Color.darkText.secondary
            complexDetailLabel.textColor = AppColor.base
            complexDetailLabel.font = UIFont(name: complexDetailLabel.font.fontName, size: 13.0)!
            complexImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
            complexImageView.image = Icon.cm.star!.withRenderingMode(.alwaysTemplate)
            complexImageView.isUserInteractionEnabled = true
            complexImageView.tintColor = stockTicker!.starred ? AppColor.base : Color.grey.base
        }
    }

    func handleTap(_ sender: UITapGestureRecognizer) {
        stockTicker!.toggleStarred()
        complexImageView.tintColor = stockTicker!.starred ? AppColor.base : Color.grey.base
    }

    func removeSimpleCell() {
        simpleLabel.removeFromSuperview()
    }

    func buildSimpleCell() {
        customView.addSubview(simpleLabel)
        simpleLabel.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(contentView)
            make.top.equalTo(contentView)
            make.left.equalTo(contentView).offset(10.0)
            make.right.equalTo(contentView).offset(-10.0)
        }
    }

    func removeComplexCell() {
        complexTitleLabel.removeFromSuperview()
        complexDetailLabel.removeFromSuperview()
        complexImageView.removeFromSuperview()
        stockTicker = nil
    }

    func buildComplexCell() {
        customView.addSubview(complexTitleLabel)
        customView.addSubview(complexDetailLabel)
        customView.addSubview(complexImageView)

        complexTitleLabel.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(complexDetailLabel.snp.top)
            make.height.equalTo(complexDetailLabel)
            make.top.equalTo(contentView).offset(10.0)
            make.left.equalTo(contentView).offset(10.0)
            make.right.equalTo(complexImageView.snp.left).offset(-5.0)
        }

        complexDetailLabel.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(contentView).offset(-10.0)
            make.height.equalTo(complexTitleLabel)
            make.top.equalTo(complexTitleLabel.snp.bottom)
            make.left.equalTo(contentView).offset(10.0)
            make.right.equalTo(complexImageView.snp.left).offset(-5.0)
        }

        complexImageView.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(contentView).offset(-15.0)
            make.right.equalTo(contentView).offset(-8.0)
            make.top.equalTo(contentView).offset(15.0)
            make.width.equalTo(30.0)
        }
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {

    var isSimpleCell: Bool {
        if searchMode || starredMode {
            return false
        }
        return selectedSector.isEmpty || (selectedSectorIndustry.isEmpty && selectedSector != "n/a")
    }

    func addTableViewContraints() {
        tableView.snp.remakeConstraints { make -> Void in
            make.bottom.equalTo(bottomTabBar.snp.top)
            make.left.equalTo(view)
            make.right.equalTo(view)
            if searchMode {
                make.top.equalTo(searchBar.snp.bottom)
            } else {
                make.top.equalTo(toolbar.snp.bottom)
            }
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
        return isSimpleCell ? 44.0 : 60.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getNumberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = (indexPath as NSIndexPath).row
        let cell = (tableView.dequeueReusableCell(withIdentifier: "cell") as? CustomTableViewCell) ?? CustomTableViewCell.init(style: .default, reuseIdentifier: "cell")
        cell.isSimpleCell = isSimpleCell
        if isSimpleCell {
            cell.simpleLabel.text = getTextForRow(row)
        } else {
            let ticker = getTickerForRow(row)
            cell.stockTicker = ticker
            cell.complexTitleLabel.text = getTextForRow(row)
            cell.complexDetailLabel.text = ticker.name
        }
        cell.applyCustomStyle()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !searchMode && !starredMode {
            if selectedSector.isEmpty {
                selectedSector = distinctSectors[indexPath.row]
            } else if selectedSectorIndustry.isEmpty && selectedSector != "n/a" {
                selectedSectorIndustry = distinctSectorIndustries[indexPath.row]
            } else {
                let stockViewController = StockViewController()
                stockViewController.selectedTicker = sectorTickers[indexPath.row]
                app.setRootViewController(view: stockViewController)
            }
        } else {
            let stockViewController = StockViewController()
            stockViewController.selectedTicker = sectorTickers[indexPath.row]
            app.setRootViewController(view: stockViewController)
        }
    }

    func scrollTableViewToTop() {
        tableView.scrollToRow(at: IndexPath(row: Foundation.NSNotFound, section: 0), at: .top, animated: false)
    }

    func getNumberOfRows() -> Int {
        if starredMode && !searchMode {
            return starred.count
        }
        if (selectedSectorIndustry.isNotEmpty || selectedSector == "n/a") && !starredMode {
            return sectorTickers.count
        }
        if selectedSector.isNotEmpty && !starredMode && !searchMode {
            return distinctSectorIndustries.count
        }
        if searchMode {
            if searchText.isEmpty {
                return tickers.count
            } else {
                return searchTickers.count.isEmpty ? searchNames.count : searchTickers.count
            }
        }
        return distinctSectors.count
    }

    func getTextForRow(_ row: Int) -> String {
        if starredMode && !searchMode {
            return getTickerForRow(row).symbol
        }
        if (selectedSectorIndustry.isNotEmpty || selectedSector == "n/a") && !starredMode {
            return getTickerForRow(row).symbol
        }
        if selectedSector.isNotEmpty && !starredMode && !searchMode {
            return distinctSectorIndustries[row]
        }
        if searchMode {
            return getTickerForRow(row).symbol
        }
        return distinctSectors[row] == "n/a" ? "Other" : distinctSectors[row]
    }

    func getTickerForRow(_ row: Int) -> StockTicker {
        if starredMode && !searchMode {
            return starred[row]
        }
        if (selectedSectorIndustry.isNotEmpty || selectedSector == "n/a") && !starredMode {
            return sectorTickers[row]
        }
        if searchMode {
            if searchText.isEmpty {
                return tickers[row]
            } else {
                return searchTickers.count.isEmpty ? searchNames[row] : searchTickers[row]
            }
        }
        return tickers[row]
    }

}

extension ViewController: TextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        tableView.reloadData()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        tableView.reloadData()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string).uppercased()
        let positionOriginal = textField.beginningOfDocument
        let cursorLocation = textField.position(from: positionOriginal, offset: (range.location + NSString(string: string).length))
        textField.text = searchText
        if cursorLocation != nil {
            textField.selectedTextRange = textField.textRange(from: cursorLocation!, to: cursorLocation!)
        }
        tableView.reloadData()
        return false
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchText = ""
        if selectedSector == "n/a" || (selectedSector.isNotEmpty && selectedSectorIndustry.isNotEmpty) {
            handleSearchBackButtonPressed()
        } else {
            tableView.reloadData()
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBar.textField.resignFirstResponder()
        tableView.reloadData()
        return true
    }

}

extension ViewController {

    func addToolbarOrSearchBarConstraints() {
        if searchMode {
            addSearchBarContraints()
        } else {
            addToolbarContraints()
        }
    }

    func addToolbarContraints() {
        toolbar.snp.remakeConstraints { make -> Void in
            make.bottom.equalTo(tableView.snp.top)
            make.height.equalTo(50.0)
            make.top.width.equalTo(view)
        }
    }

    func addSearchBarContraints() {
        searchBar.snp.remakeConstraints { make -> Void in
            make.bottom.equalTo(tableView.snp.top)
            make.height.equalTo(50.0)
            make.top.width.equalTo(view)
        }
    }

    func createToolbar() {
        toolbar = Toolbar()
        toolbar.backgroundColor = AppColor.base
        toolbar.detailLabel.textColor = Color.white
        toolbar.titleLabel.textColor = Color.white
        toolbarSettingsButton = createToolbarSettingsButton()
        toolbar.leftViews = [ toolbarSettingsButton ]
        toolbar.rightViews = [ createToolbarSearchButton() ]
        setToolbarTitle()
        setToolbarSubtitle()
        toolbarBackButton = createToolbarBackButton()
        selectedSector.isEmpty ? hideToolbarBackButton() : showToolbarBackButton()
    }

    func showToolbar() {
        view.addSubview(toolbar)
    }

    func hideToolbar() {
        toolbar.removeFromSuperview()
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

    func createToolbarSettingsButton() -> IconButton {
        let searchImage = Icon.cm.settings
        let searchButton = IconButton()
        searchButton.pulseColor = Color.white
        searchButton.tintColor = Color.white
        searchButton.setImage(searchImage, for: .normal)
        searchButton.setImage(searchImage, for: .highlighted)
        searchButton.addTarget(self, action: #selector(handleToolbarSettingsButtonPressed), for: .touchUpInside)
        return searchButton
    }

    func createToolbarSearchButton() -> IconButton {
        let searchImage = Icon.cm.search
        let searchButton = IconButton()
        searchButton.pulseColor = Color.white
        searchButton.tintColor = Color.white
        searchButton.setImage(searchImage, for: .normal)
        searchButton.setImage(searchImage, for: .highlighted)
        searchButton.addTarget(self, action: #selector(handleToolbarSearchButtonPressed), for: .touchUpInside)
        return searchButton
    }

    func showToolbarBackButton() {
        toolbar.leftViews = [ toolbarBackButton ]
    }

    func hideToolbarBackButton() {
        toolbar.leftViews = [ toolbarSettingsButton ]
    }

    func handleToolbarBackButtonPressed() {
        if selectedSectorIndustry.isEmpty {
            selectedSector = ""
        } else {
            selectedSectorIndustry = ""
        }
    }

    func handleToolbarSettingsButtonPressed() {
        app.setRootViewController(view: SettingsViewController())
    }

    func handleToolbarSearchButtonPressed() {
        searchMode = true
    }

    func setToolbarTitle() {
        if starredMode {
            toolbar.title = "Watchlist"
        } else {
            if selectedSector.isEmpty {
                toolbar.title = appName
            } else {
                if selectedSector == "n/a" {
                    toolbar.title = "Other"
                } else {
                    toolbar.title = selectedSector
                }
            }
        }
    }

    func setToolbarSubtitle() {
        toolbar.detail = starredMode ? nil : selectedSectorIndustry
    }

    func createSearchBar() {
        searchBar = SearchBar()
        searchBar.backgroundColor = AppColor.base
        searchBar.placeholderColor = Color.white
        searchBar.textColor = Color.white
        searchBar.textField.autocapitalizationType = .allCharacters
        searchBar.textField.autocorrectionType = .no
        searchBar.textField.spellCheckingType = .no
        searchBar.tintColor = Color.white
        let image = Icon.cm.arrowBack
        let button = IconButton()
        button.pulseColor = Color.white
        button.tintColor = Color.white
        button.setImage(image, for: .normal)
        button.setImage(image, for: .highlighted)
        button.addTarget(self, action: #selector(handleSearchBackButtonPressed), for: .touchUpInside)
        searchBar.leftViews = [ button ]
        searchBar.textField.delegate = self
    }

    func handleSearchBackButtonPressed() {
        searchBar.textField.resignFirstResponder()
        searchMode = false
        searchText = ""
        searchBar.textField.text = ""
        tableView.reloadData()
    }

    func showToolbarOrSearchBar() {
        if searchMode {
            if let _ = toolbar.superview {
                hideToolbar()
            }
            showSearchBar()
        } else {
            if let _ = searchBar.superview {
                hideSearchBar()
            }
            showToolbar()
        }
        if let _ = tableView.superview, let _ = bottomTabBar.superview {
            addContraintsToViews()
        }
        tableView.reloadData()
    }

    func showSearchBar() {
        view.addSubview(searchBar)
        searchBar.textField.becomeFirstResponder()
    }

    func hideSearchBar() {
        searchBar.textField.resignFirstResponder()
        searchBar.removeFromSuperview()
    }

}

extension ViewController: UITabBarDelegate {

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        searchMode = false
        searchText = ""
        searchBar.textField.text = ""
        starredMode = item.title == "Watchlist"
        if item.title == "Analysis" {
            app.setRootViewController(view: AnalysisViewController())
        } else {
            previousSelectedTab = item
        }
    }

    func addTabBarContraints() {
        bottomTabBar.snp.remakeConstraints { make -> Void in
            make.height.equalTo(50.0)
            make.top.equalTo(tableView.snp.bottom)
            make.width.equalTo(view)
        }
    }

    fileprivate func createTabBar() {
        bottomTabBar = BottomTabBar()
        bottomTabBar.backgroundColor = Color.grey.darken4
        bottomTabBar.delegate = self
        view.addSubview(bottomTabBar)

        let discoverItem = UITabBarItem(title: "Discover", image: Icon.cm.audioLibrary, selectedImage: nil)
        discoverItem.setTitleColor(color: Color.grey.base, forState: .normal)
        discoverItem.setTitleColor(color: AppColor.base, forState: .selected)

        let analysisItem = UITabBarItem(title: "Analysis", image: Icon.cm.share, selectedImage: nil)
        analysisItem.setTitleColor(color: Color.grey.base, forState: .normal)
        analysisItem.setTitleColor(color: AppColor.base, forState: .selected)

        let starredItem = UITabBarItem(title: "Watchlist", image: Icon.cm.star, selectedImage: nil)
        starredItem.setTitleColor(color: Color.grey.base, forState: .normal)
        starredItem.setTitleColor(color: AppColor.base, forState: .selected)

        bottomTabBar.itemPositioning = .automatic
        bottomTabBar.setItems([ discoverItem, analysisItem, starredItem ], animated: true)
        bottomTabBar.selectedItem = starred.isEmpty ? discoverItem : starredItem
        bottomTabBar.tintColor = AppColor.base

        starredMode = !starred.isEmpty
        previousSelectedTab = starred.isEmpty ? bottomTabBar.items?[0] : bottomTabBar.items?[2]
    }

}
