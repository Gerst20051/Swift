import Material
import SnapKit

class AnalysisViewController: BaseViewController {

    fileprivate var toolbar: Toolbar!
    fileprivate var bottomTabBar: BottomTabBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
    }

    func setupInterface() {
        view.backgroundColor = .white
        createToolbar()
        createTabBar()
        addContraintsToViews()
    }

    func addContraintsToViews() {
        addToolbarContraints()
        addTabBarContraints()
    }

}

extension AnalysisViewController {

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
        toolbar.title = "Stock Analysis"
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

}

extension AnalysisViewController: UITabBarDelegate {

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title == "Analysis" {
            return
        }
        app.rootViewController.starredMode = item.title == "Watchlist"
        app.rootViewController.previousSelectedTab = app.rootViewController.bottomTabBar.items?[item.title == "Discover" ? 0 : 2]
        app.restoreRootViewController()
    }

    func addTabBarContraints() {
        bottomTabBar.snp.remakeConstraints { make -> Void in
            make.bottom.equalTo(view)
            make.height.equalTo(50.0)
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
        bottomTabBar.selectedItem = analysisItem
        bottomTabBar.tintColor = AppColor.base
    }

}
