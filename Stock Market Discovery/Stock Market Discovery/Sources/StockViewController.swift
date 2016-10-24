import Material
import SnapKit

class StockViewController: BaseViewController {

    fileprivate var toolbar: Toolbar!
    var selectedTicker: StockTicker!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
    }

    func setupInterface() {
        view.backgroundColor = .white
        createToolbar()
        updateToolbarTitle()
        createLabels()
        addContraintsToViews()
    }

    func addContraintsToViews() {
        addToolbarContraints()
    }

}

extension StockViewController {

    func createLabels() {
        let details = [
            "Price": "$" + selectedTicker.lastSalePrice,
            "Market Cap": selectedTicker.marketCap,
            "IPO Year": selectedTicker.ipoYear,
            "Sector": selectedTicker.sector,
            "Industry": selectedTicker.industry
        ]
        let keyOrder = [
            "Price",
            "Market Cap",
            "IPO Year",
            "Sector",
            "Industry"
        ]
        for (index, key) in keyOrder.enumerated() {
            let label = UILabel()
            label.text = "\(key): \(details[key]!)"
            label.textAlignment = .center
            view.addSubview(label)
            label.snp.makeConstraints { make -> Void in
                make.height.equalTo(40.0)
                make.top.equalTo(40.0 * Double(index + 2))
                make.width.equalTo(view)
            }
        }
    }

}

extension StockViewController {

    func addToolbarContraints() {
        toolbar.snp.remakeConstraints { make -> Void in
            make.height.equalTo(50.0)
            make.left.right.top.equalTo(view)
        }
    }

    func createToolbar() {
        toolbar = Toolbar()
        toolbar.backgroundColor = AppColor.base
        toolbar.detailLabel.textColor = Color.white
        toolbar.titleLabel.textColor = Color.white
        toolbar.leftViews = [ createToolbarBackButton() ]
        toolbar.title = "Stock Overview"
        view.addSubview(toolbar)
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

    func handleToolbarBackButtonPressed() {
        app.restoreRootViewController()
    }

    func updateToolbarTitle() {
        toolbar.title = selectedTicker.symbol + "  :  " + selectedTicker.exchange
        toolbar.detail = selectedTicker.name
    }

}
