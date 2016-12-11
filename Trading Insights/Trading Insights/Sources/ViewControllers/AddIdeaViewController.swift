import Material
import SnapKit
import UIKit

class AddIdeaViewController: BaseViewController {

    fileprivate var toolbar: Toolbar!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
    }

    func setupInterface() {
        view.backgroundColor = .white
        createToolbar()
        addInterfaceContraints()
    }

    func addInterfaceContraints() {
        addToolbarContraints()
    }

    func addToolbarContraints() {
        toolbar.snp.remakeConstraints { make -> Void in
            // make.bottom.equalTo(tableView.snp.top)
            make.height.equalTo(AppConstants.ToolbarHeight)
            make.top.width.equalTo(view)
        }
    }

    func createToolbar() {
        toolbar = Toolbar()
        toolbar.backgroundColor = AppColor.base
        toolbar.leftViews = [ createToolbarBackButton() ]
        toolbar.title = AppString.AddIdea
        toolbar.titleLabel.adjustsFontSizeToFitWidth = true
        toolbar.titleLabel.font = UIFont(name: AppFont.base, size: AppConstants.ToolbarFontSize)!
        toolbar.titleLabel.textColor = Color.white
        view.addSubview(toolbar)
    }

   func createToolbarBackButton() -> IconButton {
        let menuImage = UIImage(named: AppIcon.back)
        let menuButton = IconButton()
        menuButton.setImage(menuImage, for: .normal)
        menuButton.setImage(menuImage, for: .highlighted)
        menuButton.addTarget(self, action: #selector(handleToolbarBackButtonPressed), for: .touchUpInside)
        return menuButton
    }

    func handleToolbarBackButtonPressed() {
        app.sideMenuViewController?.setContentViewController(CurrentIdeasViewController(), animated: true)
    }

}
