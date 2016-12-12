import Material
import SnapKit
import UIKit
import WSTagsField

class AddIdeaViewController: BaseViewController {

    fileprivate let toolbar = Toolbar()
    fileprivate let tickerField = UITextField()
    fileprivate let tickerNameField = UITextField()
    fileprivate let ideaSourceField = UITextField()
    fileprivate let tagsField = WSTagsField()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
    }

    func setupInterface() {
        // view.backgroundColor = .white
        view.backgroundColor = .red
        createToolbar()
        createTickerField()
        createTickerNameField()
        createIdeaSourceField()
        createTagsField()
        createTagsFieldHandlers()
        addInterfaceContraints()
    }

    func addInterfaceContraints() {
        addToolbarContraints()
    }

    func addToolbarContraints() {
        toolbar.snp.makeConstraints { make -> Void in
            // make.bottom.equalTo(tableView.snp.top)
            make.height.equalTo(AppConstants.ToolbarHeight)
            make.top.width.equalTo(view)
        }
    }

    func createToolbar() {
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

    func createTickerField() {
        view.addSubview(tickerField)
    }

    func createTickerNameField() {
        view.addSubview(tickerNameField)
    }

    func createIdeaSourceField() {
        view.addSubview(ideaSourceField)
    }

    func createTagsField() {
        tagsField.backgroundColor = .white
        tagsField.placeholder = AppString.EnterIdeaIndicators
        tagsField.tintColor = AppColor.base
        tagsField.frame = CGRect(x: 0.0, y: 44.0 + 50.0, width: 200.0, height: 44.0)
        // add constraints
        view.addSubview(tagsField)
    }

    func createTagsFieldHandlers() {
        tagsField.onDidAddTag = { _ in // update local list
            print("DidAddTag => \(self.tagsField.tags)")
        }

        tagsField.onDidRemoveTag = { _ in // update local list
            print("DidRemoveTag => \(self.tagsField.tags)")
        }

        tagsField.onDidChangeText = { _, text in
            print("DidChangeText => \(text)")
        }

        tagsField.onDidBeginEditing = { _ in
            print("DidBeginEditing")
        }

        tagsField.onDidEndEditing = { _ in
            print("DidEndEditing")
        }

        tagsField.onDidChangeHeightTo = { _, height in
            print("DidChangeHeightTo => \(height)")
        }

        tagsField.onVerifyTag = { _, text in
            print("VerifyTag => \(text)")
            return true
        }
    }

}
