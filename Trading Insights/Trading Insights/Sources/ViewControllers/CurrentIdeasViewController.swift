import Material
import SnapKit
import UIKit

class CurrentIdeasViewController: BaseViewController {

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
            make.height.equalTo(80.0)
            make.top.width.equalTo(view)
        }
    }

    func createToolbar() {
        toolbar = Toolbar()
        toolbar.backgroundColor = AppColor.base
        toolbar.leftViews = [ createToolbarMenuButton() ]
        toolbar.rightViews = [ createToolbarAddButton() ]
        toolbar.title = AppString.CurrentIdeas
        toolbar.titleLabel.adjustsFontSizeToFitWidth = true
        toolbar.titleLabel.font = UIFont(name: AppFont.base, size: 32.0)!
        toolbar.titleLabel.textColor = Color.white
        view.addSubview(toolbar)
    }

   func createToolbarMenuButton() -> IconButton {
        let menuImage = UIImage(named: AppIcon.menu)
        let menuButton = IconButton()
        menuButton.setImage(menuImage, for: .normal)
        menuButton.setImage(menuImage, for: .highlighted)
        menuButton.addTarget(self, action: #selector(handleToolbarMenuButtonPressed), for: .touchUpInside)
        return menuButton
    }

    func createToolbarAddButton() -> IconButton {
        let addImage = UIImage(named: AppIcon.add)
        let addButton = IconButton()
        addButton.setImage(addImage, for: .normal)
        addButton.setImage(addImage, for: .highlighted)
        addButton.addTarget(self, action: #selector(handleToolbarAddButtonPressed), for: .touchUpInside)
        return addButton
    }

    func handleToolbarMenuButtonPressed() {
        app.showSideMenu()
    }

    func handleToolbarAddButtonPressed() {
        print("Add")
    }

}
