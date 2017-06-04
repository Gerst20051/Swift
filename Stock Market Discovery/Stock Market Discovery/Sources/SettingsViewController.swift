import Material
import SnapKit

class SettingsViewController: BaseViewController {

    fileprivate var toolbar: Toolbar!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
    }

    func setupInterface() {
        view.backgroundColor = .white
        createToolbar()
        addContraintsToViews()
    }

    func addContraintsToViews() {
        addToolbarContraints()
    }

}

extension SettingsViewController {

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
        toolbar.title = "Settings"
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
