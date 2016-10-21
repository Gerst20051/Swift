import AVKit
import AVFoundation
import Material
import NBMaterialDialogIOS
import NMPopUpViewSwift
import NVActivityIndicatorView
import ObjectMapper
import PromiseKit
import RealmSwift
import SnapKit
import SwiftyUserDefaults
import UIKit
import XCDYouTubeKit

class ViewController: BaseViewController, SwitchDelegate, UITabBarDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {

    fileprivate var toolbar: Toolbar!
    fileprivate var bottomTabBar: BottomTabBar!
    fileprivate var searchBar: SearchBar!
    fileprivate var toolbarBackButton: IconButton!
    let realm = try! Realm()
    let userDefaults = UserDefaults.standard
    var videoPlayerContainerView: UIView?
    var player: AVPlayer?
    let tableView = UITableView()
    let playlistController = PlaylistController()
    var playlists: Results<Playlist> {
        return realm.objects(Playlist.self).filter("items.@count > 0").sorted(by: [ SortDescriptor(property: "favorite", ascending: false), "name" ])
    }
    var items: Results<StringObject> {
        return realm.objects(Playlist.self).filter(NSPredicate(format: "name = %@", selectedPlaylistName)).first!.items.sorted(by: [ SortDescriptor(property: "favorite", ascending: false), "value" ])
    }
    var favorites: Results<StringObject> {
        return realm.objects(StringObject.self).filter("favorite == 1").sorted(byProperty: "value")
    }
    var searchItems: Results<StringObject> {
        if searchText.isEmpty {
            return realm.objects(StringObject.self).filter("value == ''") // return empty set
        } else {
            if favoritesMode { // search favorites
            } else if selectedPlaylistName.isNotEmpty { // search selected playlist
            } else { // search all items
            }
            return realm.objects(StringObject.self).filter(NSPredicate(format: "value CONTAINS %@", searchText)).sorted(byProperty: "value")
        }
    }
    var appName: String {
        return Bundle.main.infoDictionary!["CFBundleName"] as! String
    }
    var selectedPlaylistName: String = "" {
        didSet {
            selectedPlaylistName.isEmpty ? hideToolbarBackButton() : showToolbarBackButton()
            setToolbarTitle()
            scrollTableViewToTop()
            animateTableView(selectedPlaylistName.isEmpty)
        }
    }
    var selectedPlaylistItem: String = "" {
        didSet {
            setToolbarSubtitle()
        }
    }
    var favoritesMode: Bool = false {
        didSet {
            setToolbarTitle()
            animateTableView(true)
        }
    }
    var shuffleMode = false
    var searchMode: Bool = false {
        didSet {
            showToolbarOrSearchBar()
        }
    }
    var searchText = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Realm File Location => \(Realm.Configuration.defaultConfiguration.fileURL)")
        monitorDeviceOrientationChange()
        addSwipeGestureRecognizer()
        setupUI()
    }

    func monitorDeviceOrientationChange() {
        let notificationCenter = NotificationCenter.default
        // notificationCenter.addObserver(self, selector: #selector(ViewController.playerDidFinishPlaying), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ViewController.playerPlaybackStalled), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ViewController.deviceOrientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    func deviceOrientationDidChange() {
        addContraintsToViews()
    }

    func addSwipeGestureRecognizer() {
        for gesture in [ .left, .right, .up ] as [UISwipeGestureRecognizerDirection] {
            let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.respondToSwipeGesture(_:)))
            swipeGesture.direction = gesture
            view.addGestureRecognizer(swipeGesture)
        }
    }

    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction as UISwipeGestureRecognizerDirection {
                case UISwipeGestureRecognizerDirection.left, UISwipeGestureRecognizerDirection.right:
                    if let videoPlayerContainerView = videoPlayerContainerView {
                        let videoPlayerContainsPoint = videoPlayerContainerView.bounds.contains(swipeGesture.location(in: videoPlayerContainerView))
                        if videoPlayerContainsPoint {
                            removeVideoPlayerContainerView()
                        } else {
                            returnToListOfPlaylists()
                        }
                    } else if swipeGesture.direction == UISwipeGestureRecognizerDirection.right {
                        returnToListOfPlaylists()
                    }
                case UISwipeGestureRecognizerDirection.up:
                    if let videoPlayerContainerView = videoPlayerContainerView {
                        let videoPlayerContainsPoint = videoPlayerContainerView.bounds.contains(swipeGesture.location(in: videoPlayerContainerView))
                        if videoPlayerContainsPoint {
                            // set video full screen
                        }
                    }
                default:
                    break
            }
        }
    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        favoritesMode = item.title == "Starred"
    }

    func setupUI() {
        view.backgroundColor = Color.white
        createToolbar()
        createSearchBar()
        showToolbarOrSearchBar()
        createTableView()
        createTabBar()
        addContraintsToViews()
        createPinchGesture()
        createVideoContainerView()
        loadPlaylistData()
    }

    func addContraintsToViews() {
        addToolbarOrSearchBarConstraints()
        addTableViewContraints()
        addTabBarContraints()
        addVideoPlayerContainerContraints()
    }

    func addToolbarOrSearchBarConstraints() {
        if searchMode {
            addSearchBarContraints()
        } else {
            addToolbarContraints()
        }
    }

    func addToolbarContraints() {
        toolbar.snp.remakeConstraints { (make) -> Void in
            make.bottom.equalTo(tableView.snp.top)
            make.height.equalTo(50.0)
            make.top.width.equalTo(view)
        }
    }

    func addSearchBarContraints() {
        searchBar.snp.remakeConstraints { (make) -> Void in
            make.bottom.equalTo(tableView.snp.top)
            make.height.equalTo(50.0)
            make.top.width.equalTo(view)
        }
    }

    func addTableViewContraints() {
        tableView.snp.remakeConstraints { (make) -> Void in
            make.bottom.equalTo(bottomTabBar.snp.top)
            if searchMode {
                make.top.equalTo(searchBar.snp.bottom)
            } else {
                make.top.equalTo(toolbar.snp.bottom)
            }
            make.width.equalTo(view)
        }
    }

    func addTabBarContraints() {
        bottomTabBar.snp.remakeConstraints { (make) -> Void in
            make.height.equalTo(50.0)
            make.top.equalTo(tableView.snp.bottom)
            make.width.equalTo(view)
        }
    }

    func addVideoPlayerContainerContraints() {
        videoPlayerContainerView?.snp.remakeConstraints { (make) -> Void in
            make.bottom.equalTo(bottomTabBar.snp.top)
            make.height.equalTo(140.0)
            make.right.equalTo(0.0)
            make.width.equalTo(200.0)
        }
    }

    func loadPlaylistData() {
        showLoader()
        Cloud.downloadPlaylistVersion().then { currentPlaylistVersion -> Void in
            if self.getPlaylistVersion() == currentPlaylistVersion {
                print("playlist is up-to-date")
            } else {
                self.showLoader()
                Cloud.downloadPlaylistJSON().then { playlists -> Void in
                    Defaults[.PlaylistVersion] = currentPlaylistVersion
                    self.playlistController.clearPlaylists()
                    for playlist in playlists {
                        self.playlistController.addPlaylist(playlist)
                    }
                    self.scrollTableViewToTop()
                    self.animateTableView()
                    return
                }.always {
                    self.hideLoader()
                }.catch { error in
                    switch error {
                        case PromiseError.apiFailure(let error):
                            print("api failure => \(error)")
                        case PromiseError.invalidPlaylist:
                            print("invalid playist")
                        default:
                            print("unhandled error => \(error)")
                    }
                    self.getLocalPlaylistJSON()
                }
            }
        }.always {
            self.hideLoader()
        }.catch { error in
            switch error {
                case PromiseError.apiFailure(let error):
                    print("api failure => \(error)")
                case PromiseError.invalidPlaylistVersion:
                    print("invalid playist version")
                default:
                    print("unhandled error => \(error)")
            }
            self.getLocalPlaylistJSON()
        }
    }

    func getPlaylistVersion() -> Int {
        return Defaults[.PlaylistVersion]
    }

    func getLocalPlaylistJSON() {
        guard playlists.count.isEmpty || getPlaylistVersion().isEmpty else {
            print("failed to update playlists. using stored playlist version #\(getPlaylistVersion()).")
            return
        }
        print("loading local playlist json file")
        if let filePath = Bundle.main.path(forResource: "playlists", ofType: "json"), let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                parseLocalPlaylist(json as! [[String: AnyObject]])
            } catch let error {
                print("error parsing local json file => \(error)")
            }
        }
    }

    func parseLocalPlaylist(_ playlists: [[String: Any]]) {
        playlistController.clearPlaylists()
        for playlist in playlists {
            if let playlistObject = Mapper<Playlist>().map(JSON: playlist) {
                playlistController.addPlaylist(playlistObject)
            }
        }
        scrollTableViewToTop()
        animateTableView()
    }

    func createToolbar() {
        toolbar = Toolbar()
        toolbar.backgroundColor = Color.teal.base
        toolbar.detailLabel.textColor = Color.white
        toolbar.titleLabel.textColor = Color.white
        toolbar.leftViews = []
        toolbar.rightViews = [ createToolbarSwitchControl(), createToolbarSearchButton() ]
        setToolbarTitle()
        setToolbarSubtitle()
        toolbarBackButton = createToolbarBackButton()
        selectedPlaylistName.isEmpty ? hideToolbarBackButton() : showToolbarBackButton()
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
        backButton.addTarget(self, action: #selector(handleToolbarBackButton), for: .touchUpInside)
        return backButton
    }

    func createToolbarSwitchControl() -> Switch {
        let switchControl = Switch(state: .off, style: .light, size: .small)
        switchControl.delegate = self
        return switchControl
    }

    func createToolbarSearchButton() -> IconButton {
        let searchImage = Icon.cm.search
        let searchButton = IconButton()
        searchButton.pulseColor = Color.white
        searchButton.tintColor = Color.white
        searchButton.setImage(searchImage, for: .normal)
        searchButton.setImage(searchImage, for: .highlighted)
        searchButton.addTarget(self, action: #selector(handleToolbarSearchButton), for: .touchUpInside)
        return searchButton
    }

    func showToolbarBackButton() {
        toolbar.leftViews = [ toolbarBackButton ]
    }

    func hideToolbarBackButton() {
        toolbar.leftViews = []
    }

    func handleToolbarBackButton() {
        selectedPlaylistName = ""
    }

    func handleToolbarSearchButton() {
        print("show search toolbar")
        searchMode = true
    }

    func setToolbarTitle() {
        toolbar.title = favoritesMode ? "Favorites" : (selectedPlaylistName.isEmpty ? appName : selectedPlaylistName)
    }

    func setToolbarSubtitle() {
        toolbar.detail = selectedPlaylistItem
    }

    func switchDidChangeState(control: Switch, state: SwitchState) {
        shuffleMode = control.on
    }

    func createSearchBar() {
        searchBar = SearchBar()
        searchBar.backgroundColor = Color.teal.base
        searchBar.placeholderColor = Color.white
        searchBar.textColor = Color.white
        searchBar.tintColor = Color.white
        let image = Icon.cm.arrowBack
        let button = IconButton()
        button.pulseColor = Color.white
        button.tintColor = Color.white
        button.setImage(image, for: .normal)
        button.setImage(image, for: .highlighted)
        button.addTarget(self, action: #selector(handleSearchBackButton), for: .touchUpInside)
        searchBar.leftViews = [ button ]
        searchBar.textField.delegate = self
    }

    func handleSearchBackButton() {
        searchBar.textField.resignFirstResponder()
        searchMode = false
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
            addContraintsToViews() // TODO: maybe only re-add more specific constraints
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

    func createTableView() {
        tableView.backgroundColor = Color.clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        view.addSubview(tableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchMode ? searchItems.count : (favoritesMode ? favorites.count : (selectedPlaylistName.isEmpty ? playlists.count : items.count))
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = (indexPath as NSIndexPath).row
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.backgroundColor = Color.clear
        cell.removeMargins()
        cell.textLabel?.text = searchMode ? searchItems[row].value : (favoritesMode ? favorites[row].value : (selectedPlaylistName.isEmpty ? playlists[row].name : items[row].value))
        cell.textLabel?.textColor = Color.darkText.secondary
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedPlaylistName.isEmpty && !favoritesMode && !searchMode {
            selectedPlaylistName = playlists[indexPath.row].name
            if Defaults[.HelpOverlayShownForPinchGesture] == false {
                Defaults[.HelpOverlayShownForPinchGesture] = true
                showPopupView(image: "pinch", title: "Pinch Gesture", message: "Pinch or swipe right to return to your playlists.")
            }
        } else {
            if searchMode {
                searchBar.textField.resignFirstResponder()
            }
            let row = (indexPath as NSIndexPath).row
            selectedPlaylistItem = searchMode ? searchItems[row].value! : (favoritesMode ? favorites[row].value! : items[row].value!)
            if let apiUrl = CloudUtils.getYouTubeApiUrl(selectedPlaylistItem) {
                print("apiUrl => \(apiUrl)")
                showLoader()
                Cloud.getYouTubeVideo(apiUrl).then { (videoId: String) -> Void in
                    print("youtube video id => \(videoId)")
                    self.loadVideo(videoId)
                }.catch { error in
                    print("error loading youtube video id => \(error)")
                    self.hideLoader()
                }
            } else {
                print("error parsing youtube api url")
            }
            if Defaults[.HelpOverlayShownForSpreadGesture] == false {
                Defaults[.HelpOverlayShownForSpreadGesture] = true
                showPopupView(image: "spread", title: "Spread Gesture", message: "A spread gesture will make your video fullscreen.")
            }
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let row = (indexPath as NSIndexPath).row

        // let more = UITableViewRowAction(style: .Normal, title: "More") { action, index in
        //     print("more button tapped") // idk
        // }
        // more.backgroundColor = UIColor.lightGrayColor()

        let isFavorite = favoritesMode ? true : (searchMode ? searchItems[row].favorite : (selectedPlaylistName.isEmpty ? playlists[row].favorite : items[row].favorite))
        let favorite = UITableViewRowAction(style: .normal, title: isFavorite ? "Unfavorite" : "Favorite") { action, index in
            print("(un)favorite button tapped")
            let row = index.row
            if self.selectedPlaylistName.isEmpty && !self.favoritesMode && !self.searchMode {
                self.playlistController.toggleFavorite(self.playlists[row])
            } else {
                self.playlistController.toggleFavorite(self.searchMode ? self.searchItems[row] : (self.favoritesMode ? self.favorites[row] : self.items[row]))
            }
            self.animateTableViewCell(tableView.cellForRow(at: indexPath)!) { finished in
                self.animateTableView()
            }
        }
        favorite.backgroundColor = isFavorite ? Color.red.accent1 : Color.orange.accent1

        let share = UITableViewRowAction(style: .normal, title: "Share") { action, index in
            print("share button tapped")
            let row = (index as NSIndexPath).row
            self.handlePlaylistItemShare(self.searchMode ? self.searchItems[row].value! : (self.favoritesMode ? self.favorites[row].value! : self.items[row].value!))
        }
        share.backgroundColor = Color.blue.base

        var editActions: [UITableViewRowAction]? = []
        // editActions!.append(more)
        editActions!.append(favorite)
        if selectedPlaylistName.isNotEmpty {
            editActions!.append(share)
        }

        return editActions!.reversed()
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func animateTableViewCell(_ cell: UITableViewCell, completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: 0.5, delay: 0.06, usingSpringWithDamping: 0.0, initialSpringVelocity: 0.0, options: [], animations: {
            cell.transform = CGAffineTransform(translationX: -self.tableView.bounds.size.width, y: 0.0)
        }, completion: completion)
    }

    func animateTableView(_ directionLeft: Bool = false) {
        tableView.reloadData()
        for cell in tableView.visibleCells {
            cell.transform = CGAffineTransform(translationX: directionLeft ? -tableView.bounds.size.width : tableView.bounds.size.width, y: 0.0)
            UIView.animate(withDuration: 0.5, delay: 0.06, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.25, options: [], animations: {
                cell.transform = CGAffineTransform(translationX: 0.0, y: 0.0)
            }, completion: nil)
        }
    }

    func handlePlaylistItemShare(_ searchTerm: String) {
        if let apiUrl = CloudUtils.getYouTubeApiUrl(searchTerm) {
            showLoader()
            Cloud.getYouTubeVideo(apiUrl).then { (videoId: String) -> Void in
                print("sharing youtube video id => \(videoId)")
                UIPasteboard.general.string = "https://www.youtube.com/watch?v=\(videoId)"
                // NBMaterialToast.showWithText(self.view, text: "A Sharable Link To This Video Has Been Copied To Your Clipboard")
            }.always {
                self.hideLoader()
                self.tableView.setEditing(false, animated: true)
            }.catch { error in
                print("error loading youtube video id => \(error)")
            }
        } else {
            print("error parsing youtube api url")
        }
    }

    func scrollTableViewToTop() {
        tableView.scrollToRow(at: IndexPath(row: Foundation.NSNotFound, section: 0), at: .top, animated: false)
    }

    fileprivate func createTabBar() {
        bottomTabBar = BottomTabBar()
        bottomTabBar.backgroundColor = Color.grey.darken4
        bottomTabBar.delegate = self
        view.addSubview(bottomTabBar)

        let libraryItem = UITabBarItem(title: "Library", image: Icon.cm.audioLibrary, selectedImage: nil)
        libraryItem.setTitleColor(color: Color.grey.base, forState: .normal)
        libraryItem.setTitleColor(color: Color.teal.base, forState: .selected)

        let starredItem = UITabBarItem(title: "Starred", image: Icon.cm.star, selectedImage: nil)
        starredItem.setTitleColor(color: Color.grey.base, forState: .normal)
        starredItem.setTitleColor(color: Color.teal.base, forState: .selected)

        bottomTabBar.itemPositioning = .automatic
        bottomTabBar.setItems([ libraryItem, starredItem ], animated: true)
        bottomTabBar.selectedItem = libraryItem
        bottomTabBar.tintColor = Color.teal.base
    }

    func createPinchGesture() {
        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.detectPinch(_:)))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }

    func detectPinch(_ sender: UIPinchGestureRecognizer) {
        if sender.scale > 1.0 { // spread gesture
            // set video full screen
        } else { // pinch gesture
            returnToListOfPlaylists()
        }
    }

    func returnToListOfPlaylists() {
        if !loader.animating {
            hideLoader()
            if selectedPlaylistName.isNotEmpty {
                selectedPlaylistName = ""
            }
        }
    }

    func createVideoContainerView() {
        guard videoPlayerContainerView == nil else { return }
        videoPlayerContainerView = UIView()
        videoPlayerContainerView!.isHidden = true
        view.addSubview(videoPlayerContainerView!)
        addVideoPlayerContainerContraints()
    }

    func loadVideo(_ videoId: String) {
        createVideoContainerView()
        guard let containerView = videoPlayerContainerView else { return }
        XCDYouTubeClient.default().getVideoWithIdentifier(videoId) { [unowned containerView] (video: XCDYouTubeVideo?, error: Error?) in
            if let streamURL = video?.streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? video?.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue] ?? video?.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue] ?? video?.streamURLs[XCDYouTubeVideoQuality.small240.rawValue] {
                let playerItem = AVPlayerItem(url: streamURL)
                NotificationCenter.default.addObserver(self, selector: #selector(ViewController.playerDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
                self.player = AVPlayer(playerItem: playerItem)
                // self.player.delegate = self
                let playerLayer = AVPlayerLayer()
                playerLayer.player = self.player
                playerLayer.frame = CGRect(origin: CGPoint.zero, size: containerView.frame.size)
                // playerLayer.backgroundColor = UIColor.blackColor().CGColor
                // playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                containerView.layer.addSublayer(playerLayer)
                self.player!.play()
                self.videoReceived() // need to add this to a new delegate method
            }
        }
    }

    func removeVideoPlayerContainerView() {
        videoPlayerContainerView?.isHidden = true
        player?.pause() // how to stop video
        videoPlayerContainerView?.removeFromSuperview()
        videoPlayerContainerView = nil
        selectedPlaylistItem = ""
    }

    func videoReceived() {
        videoPlayerContainerView?.isHidden = false
        hideLoader()
    }

    func playerDidFinishPlaying(_ notification: Notification) {
        print("playerDidFinishPlaying notification")
    }

    func playerDidFinishPlaying() {
        print("playerDidFinishPlaying")
    }

    func playerPlaybackStalled() {
        print("playerPlaybackStalled")
    }

    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
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
        tableView.reloadData()
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        tableView.reloadData()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBar.textField.resignFirstResponder()
        tableView.reloadData()
        return true
    }
}
