import Material
import RateLimit
import SnapKit
import SwiftSpinner
import UIKit

class ViewController: BaseViewController {

    fileprivate var toolbar: Toolbar!
    fileprivate var searchBar: SearchBar!
    fileprivate var toolbarBackButton: IconButton!
    fileprivate var toolbarSettingsButton: IconButton!
    var bottomTabBar: BottomTabBar!
    // let realm = try! Realm()
    let tableView = UITableView()
    var appName: String {
        return Bundle.main.infoDictionary!["CFBundleName"] as! String
    }
    var searchMode: Bool = false {
        didSet {
            showToolbarOrSearchBar()
        }
    }
    var searchText: String = "" {
        didSet {
            if searchText.isEmpty {
                podcastSearchResults = []
                scrollTableViewToTop()
                tableView.reloadData()
            } else {
                searchLimiter?.execute()
            }
        }
    }
    var podcastSearchResults: [PodcastSearchResult] = []
    var podcastFeedResult: PodcastFeedResult?
    var searchLimiter: DebouncedLimiter?

    override func viewDidLoad() {
        super.viewDidLoad()
        RealmUtils.logDebugInfo()
        searchLimiter = DebouncedLimiter(limit: 1.0, block: search)
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
    }

    func addContraintsToViews() {
        addToolbarOrSearchBarConstraints()
        addTableViewContraints()
        addTabBarContraints()
    }

}

extension ViewController {

    func search() {
        _ = Cloud.searchPodcasts(keywords: searchText).then { podcasts -> Void in
            self.podcastSearchResults = podcasts
            self.scrollTableViewToTop()
            self.tableView.reloadData()
            for podcast in podcasts {
                print("\(podcast.title!) - \(podcast.url!)")
            }
        }.catch { error in
            print("error => \(error)")
        }
    }

    func podcastFeed(url: String) {
        SwiftSpinner.show("Loading...")
        _ = Cloud.retrievePodcastFeed(url: url).then { podcastFeed -> Void in
            self.podcastFeedResult = podcastFeed
            self.scrollTableViewToTop() // TEMPORARY
            self.tableView.reloadData() // TEMPORARY
            for episode in podcastFeed.episodes! {
                print("\(episode.title!) - \(episode.url!)")
            }
        }.always {
            SwiftSpinner.hide()
        }.catch { error in
            print("error => \(error)")
        }
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

    let customView = UIView()
    let simpleLabel = UILabel()

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
        buildSimpleCell()
        simpleLabel.textColor = Color.darkText.secondary
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

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {

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
        return 44.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getNumberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = (indexPath as NSIndexPath).row
        let cell = (tableView.dequeueReusableCell(withIdentifier: "cell") as? CustomTableViewCell) ?? CustomTableViewCell.init(style: .default, reuseIdentifier: "cell")
        cell.simpleLabel.text = getTextForRow(row)
        cell.applyCustomStyle()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: navigate to podcast view controller
        if podcastFeedResult == nil || podcastFeedResult!.episodes!.isEmpty { // TEMPORARY
            searchBar.textField.resignFirstResponder()
            podcastFeed(url: podcastSearchResults[indexPath.row].url!)
        } else {
            let episodeViewController = EpisodeViewController()
            episodeViewController.podcastFeed = podcastFeedResult
            episodeViewController.podcastEpisodeId = podcastFeedResult!.episodes![indexPath.row].id
            app.setRootViewController(view: episodeViewController)
        }
    }

    func scrollTableViewToTop() {
        tableView.scrollToRow(at: IndexPath(row: Foundation.NSNotFound, section: 0), at: .top, animated: false)
    }

    func getNumberOfRows() -> Int {
        if let feed = podcastFeedResult, feed.episodes!.isNotEmpty { // TEMPORARY
            return feed.episodes!.count
        }
        return podcastSearchResults.count
    }

    func getTextForRow(_ row: Int) -> String {
        if let feed = podcastFeedResult, feed.episodes!.isNotEmpty { // TEMPORARY
            return feed.episodes![row].title!
        }
        return podcastSearchResults[row].title!.replacingOccurrences(of: "&amp;", with: "&")
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
        searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
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
        tableView.reloadData()
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
        toolbarBackButton = createToolbarBackButton()
        hideToolbarBackButton()
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

    func handleToolbarBackButtonPressed() {}

    func handleToolbarSettingsButtonPressed() {
        // app.setRootViewController(view: SettingsViewController())
    }

    func handleToolbarSearchButtonPressed() {
        searchMode = true
    }

    func setToolbarTitle() {
        toolbar.title = appName
    }

    func createSearchBar() {
        searchBar = SearchBar()
        searchBar.backgroundColor = AppColor.base
        searchBar.placeholderColor = Color.white
        searchBar.textColor = Color.white
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
        if let _ = podcastFeedResult { // TEMPORARY
            podcastFeedResult = nil
            tableView.reloadData()
            searchBar.textField.becomeFirstResponder()
            return
        }
        searchBar.textField.resignFirstResponder()
        searchMode = false
        podcastSearchResults = []
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

        let podcastsTabItem = UITabBarItem(title: "Podcasts", image: Icon.cm.audioLibrary, selectedImage: nil)
        podcastsTabItem.setTitleColor(color: Color.grey.base, forState: .normal)
        podcastsTabItem.setTitleColor(color: AppColor.base, forState: .selected)

        let playerTabItem = UITabBarItem(title: "Player", image: Icon.cm.audio, selectedImage: nil)
        playerTabItem.setTitleColor(color: Color.grey.base, forState: .normal)
        playerTabItem.setTitleColor(color: AppColor.base, forState: .selected)

        let playlistsTabItem = UITabBarItem(title: "Playlists", image: Icon.cm.star, selectedImage: nil)
        playlistsTabItem.setTitleColor(color: Color.grey.base, forState: .normal)
        playlistsTabItem.setTitleColor(color: AppColor.base, forState: .selected)

        bottomTabBar.itemPositioning = .automatic
        bottomTabBar.setItems([ podcastsTabItem, playerTabItem, playlistsTabItem ], animated: true)
        bottomTabBar.selectedItem = podcastsTabItem
        bottomTabBar.tintColor = AppColor.base
    }

}
