import Material
import SnapKit
import UIKit
import WSTagsField

class SettingsViewController: BaseViewController {

    fileprivate let toolbar = Toolbar()
    fileprivate let scrollView = UIScrollView()
    fileprivate let sentimentLabel = UILabel()
    fileprivate let sentimentTagsField = WSTagsField()
    fileprivate let holdingDurationLabel = UILabel()
    fileprivate let holdingDurationTagsField = WSTagsField()
    fileprivate let ideaSourcesLabel = UILabel()
    fileprivate let ideaSourcesTagsField = WSTagsField()
    fileprivate let ideaIndicatorsLabel = UILabel()
    fileprivate let ideaIndicatorsTagsField = WSTagsField()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
    }

    func setupInterface() {
        view.backgroundColor = .white
        createToolbar()
        createScrollView()
        createSentimentTagsField()
        createHoldingDurationTagsField()
        createIdeaSourcesTagsField()
        createIdeaIndicatorsTagsField()
        addInterfaceContraints()
        addTags()
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
        addTagFieldContraints()
    }

}

extension SettingsViewController {

    func addToolbarContraints() {
        toolbar.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(scrollView.snp.top)
            make.height.equalTo(AppConstants.ToolbarHeight)
            make.top.width.equalTo(view)
        }
    }

    func createToolbar() {
        toolbar.backgroundColor = AppColor.base
        toolbar.leftViews = [ createToolbarMenuButton() ]
        toolbar.title = AppString.Settings
        toolbar.titleLabel.adjustsFontSizeToFitWidth = true
        toolbar.titleLabel.font = UIFont(name: AppFont.base, size: AppConstants.ToolbarFontSize)!
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

    func handleToolbarMenuButtonPressed() {
        app.showSideMenu()
    }

}

extension SettingsViewController {

    func addTagFieldContraints() {
        sentimentLabel.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(sentimentTagsField.snp.top)
            make.height.equalTo(50.0)
            make.left.equalTo(8.0)
            make.right.top.equalTo(scrollView)
        }
        sentimentTagsField.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(holdingDurationLabel.snp.top)
            make.top.equalTo(sentimentLabel.snp.bottom)
            make.width.equalTo(scrollView)
        }
        holdingDurationLabel.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(holdingDurationTagsField.snp.top)
            make.height.equalTo(50.0)
            make.left.equalTo(8.0)
            make.right.equalTo(scrollView)
            make.top.equalTo(sentimentTagsField.snp.bottom)
        }
        holdingDurationTagsField.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(ideaSourcesLabel.snp.top)
            make.top.equalTo(holdingDurationLabel.snp.bottom)
            make.width.equalTo(scrollView)
        }
        ideaSourcesLabel.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(ideaSourcesTagsField.snp.top)
            make.height.equalTo(50.0)
            make.left.equalTo(8.0)
            make.right.equalTo(scrollView)
            make.top.equalTo(holdingDurationTagsField.snp.bottom)
        }
        ideaSourcesTagsField.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(ideaIndicatorsLabel.snp.top)
            make.top.equalTo(ideaSourcesLabel.snp.bottom)
            make.width.equalTo(scrollView)
        }
        ideaIndicatorsLabel.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(ideaIndicatorsTagsField.snp.top)
            make.height.equalTo(50.0)
            make.left.equalTo(8.0)
            make.right.equalTo(scrollView)
            make.top.equalTo(ideaSourcesTagsField.snp.bottom)
        }
        ideaIndicatorsTagsField.snp.makeConstraints { make -> Void in
            make.bottom.width.equalTo(scrollView)
            make.top.equalTo(ideaIndicatorsLabel.snp.bottom)
        }
    }

    func createSentimentTagsField() {
        sentimentLabel.font = UIFont(name: AppFont.sectionHeader, size: AppConstants.SectionHeaderFontSize)
        sentimentLabel.text = AppString.SentimentTags
        sentimentLabel.textColor = AppColor.sectionHeader
        scrollView.addSubview(sentimentLabel)

        sentimentTagsField.backgroundColor = .white
        sentimentTagsField.isUserInteractionEnabled = false
        sentimentTagsField.tintColor = AppColor.tag
        scrollView.addSubview(sentimentTagsField)
    }

    func createHoldingDurationTagsField() {
        holdingDurationLabel.font = UIFont(name: AppFont.sectionHeader, size: AppConstants.SectionHeaderFontSize)
        holdingDurationLabel.text = AppString.HoldingDurationTags
        holdingDurationLabel.textColor = AppColor.sectionHeader
        scrollView.addSubview(holdingDurationLabel)

        holdingDurationTagsField.backgroundColor = .white
        holdingDurationTagsField.isUserInteractionEnabled = false
        holdingDurationTagsField.tintColor = AppColor.tag
        scrollView.addSubview(holdingDurationTagsField)
    }

    func createIdeaSourcesTagsField() {
        ideaSourcesLabel.font = UIFont(name: AppFont.sectionHeader, size: AppConstants.SectionHeaderFontSize)
        ideaSourcesLabel.text = AppString.IdeaSourceTags
        ideaSourcesLabel.textColor = AppColor.sectionHeader
        scrollView.addSubview(ideaSourcesLabel)

        ideaSourcesTagsField.backgroundColor = .white
        ideaSourcesTagsField.isUserInteractionEnabled = false
        ideaSourcesTagsField.tintColor = AppColor.tag
        scrollView.addSubview(ideaSourcesTagsField)
    }

    func createIdeaIndicatorsTagsField() {
        ideaIndicatorsLabel.font = UIFont(name: AppFont.sectionHeader, size: AppConstants.SectionHeaderFontSize)
        ideaIndicatorsLabel.text = AppString.IdeaIndicatorTags
        ideaIndicatorsLabel.textColor = AppColor.sectionHeader
        scrollView.addSubview(ideaIndicatorsLabel)

        ideaIndicatorsTagsField.backgroundColor = .white
        ideaIndicatorsTagsField.isUserInteractionEnabled = false
        ideaIndicatorsTagsField.tintColor = AppColor.tag
        scrollView.addSubview(ideaIndicatorsTagsField)
    }

    func addTags() {
        view.setNeedsLayout()
        view.layoutIfNeeded()
        sentimentTagsField.addTags(IdeaSentimentRealmController.defaultSentiments)
        holdingDurationTagsField.addTags(IdeaHoldingDurationRealmController.defaultHoldingDurations)
        ideaSourcesTagsField.addTags(IdeaSourceRealmController.defaultSources)
        ideaIndicatorsTagsField.addTags(IdeaIndicatorRealmController.defaultIndicators)
    }

}
