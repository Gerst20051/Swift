import Material
import SnapKit
import UIKit
import WSTagsField

class AddIdeaViewController: BaseViewController {

    fileprivate let toolbar = Toolbar()
    fileprivate let scrollView = UIScrollView()
    fileprivate let tickerField = UITextField()
    fileprivate let tickerNameField = UITextField()
    fileprivate let ideaSourceField = UITextField()
    fileprivate let ideaSentimentField = UITextField()
    fileprivate let tradedField = UITextField()
    fileprivate let holdingDurationField = UITextField()
    fileprivate let tagsField = WSTagsField()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
    }

    func setupInterface() {
        view.backgroundColor = .white
        createToolbar()
        createScrollView()
        createTickerField()
        createTickerNameField()
        createIdeaSourceField()
        createIdeaSentimentField()
        createTradedField()
        createHoldingDurationField()
        createTagsField()
        createTagsFieldHandlers()
        addInterfaceContraints()
    }

    func createScrollView() {
        view.addSubview(scrollView)
    }

    func addScrollViewContraints() {
        scrollView.snp.makeConstraints { make -> Void in
            make.bottom.width.equalTo(view)
            make.top.equalTo(toolbar.snp.bottom)
        }
    }

    func addInterfaceContraints() {
        addToolbarContraints()
        addScrollViewContraints()
        addFieldContraints()
    }

}

extension AddIdeaViewController {

    func addToolbarContraints() {
        toolbar.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(scrollView.snp.top)
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
        app.sideMenuViewController.setContentViewController(CurrentIdeasViewController(), animated: true)
    }

}

extension AddIdeaViewController: UITextFieldDelegate {

    func addFieldContraints() {
        let margin: CGFloat = 12.0
        tickerField.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(tickerNameField.snp.top).offset(-2.0 * margin)
            make.left.equalTo(scrollView).offset(margin)
            make.top.equalTo(scrollView).offset(2.0 * margin)
            make.width.equalTo(scrollView).offset(-2.0 * margin)
        }
        tickerNameField.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(ideaSourceField.snp.top).offset(-2.0 * margin)
            make.left.equalTo(scrollView).offset(margin)
            make.top.equalTo(tickerField.snp.bottom).offset(2.0 * margin)
            make.width.equalTo(scrollView).offset(-2.0 * margin)
        }
        ideaSourceField.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(ideaSentimentField.snp.top).offset(-2.0 * margin)
            make.left.equalTo(scrollView).offset(margin)
            make.top.equalTo(tickerNameField.snp.bottom).offset(2.0 * margin)
            make.width.equalTo(scrollView).offset(-2.0 * margin)
        }
        ideaSentimentField.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(tradedField.snp.top).offset(-2.0 * margin)
            make.left.equalTo(scrollView).offset(margin)
            make.top.equalTo(ideaSourceField.snp.bottom).offset(2.0 * margin)
            make.width.equalTo(scrollView).offset(-2.0 * margin)
        }
        tradedField.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(holdingDurationField.snp.top).offset(-2.0 * margin)
            make.left.equalTo(scrollView).offset(margin)
            make.top.equalTo(ideaSentimentField.snp.bottom).offset(2.0 * margin)
            make.width.equalTo(scrollView).offset(-2.0 * margin)
        }
        holdingDurationField.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(tagsField.snp.top).offset(-margin) // tagsField already has a margin
            make.left.equalTo(scrollView).offset(margin)
            make.top.equalTo(tradedField.snp.bottom).offset(2.0 * margin)
            make.width.equalTo(scrollView).offset(-2.0 * margin)
        }
        tagsField.snp.makeConstraints { make -> Void in
            make.height.equalTo(44.0)
            make.top.equalTo(holdingDurationField.snp.bottom).offset(margin)
            make.width.equalTo(scrollView)
        }
    }

    func createTickerField() {
        tickerField.delegate = self
        tickerField.placeholder = "Ticker"
        tickerField.tintColor = AppColor.tag
        scrollView.addSubview(tickerField)
    }

    func createTickerNameField() {
        tickerNameField.delegate = self
        tickerNameField.placeholder = "Name"
        tickerNameField.tintColor = AppColor.tag
        scrollView.addSubview(tickerNameField)
    }

    func createIdeaSourceField() {
        ideaSourceField.delegate = self
        ideaSourceField.placeholder = "Source"
        ideaSourceField.tintColor = AppColor.tag
        scrollView.addSubview(ideaSourceField)
    }

    func createIdeaSentimentField() {
        ideaSentimentField.delegate = self
        ideaSentimentField.placeholder = "Sentiment"
        ideaSentimentField.tintColor = AppColor.tag
        scrollView.addSubview(ideaSentimentField)
    }

    func createTradedField() {
        tradedField.delegate = self
        tradedField.placeholder = "Traded"
        tradedField.tintColor = AppColor.tag
        scrollView.addSubview(tradedField)
    }

    func createHoldingDurationField() {
        holdingDurationField.delegate = self
        holdingDurationField.placeholder = "Holding Duration"
        holdingDurationField.tintColor = AppColor.tag
        scrollView.addSubview(holdingDurationField)
    }

    func createTagsField() {
        tagsField.backgroundColor = .white
        tagsField.placeholder = AppString.EnterIdeaIndicators
        tagsField.tintColor = AppColor.tag
        scrollView.addSubview(tagsField)
        // need to scroll up scrollview when keyboard is open
    }

    func createTagsFieldHandlers() {
        tagsField.onDidAddTag = { _ in // update local list
            print("DidAddTag => \(self.tagsField.tags)")
        }
        tagsField.onDidRemoveTag = { _ in // update local list
            print("DidRemoveTag => \(self.tagsField.tags)")
        }
        tagsField.onDidChangeText = { _, text in // use this to update an autocomplete list?
            print("DidChangeText => \(text)")
        }
        tagsField.onShouldReturn = { tagsField -> Bool in
            tagsField.endEditing()
            return false
        }
        tagsField.onVerifyTag = { _, text in
            print("VerifyTag => \(text)")
            return true
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.isEqual(tickerField) {
            tickerField.text = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string.uppercased())
            return false
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
