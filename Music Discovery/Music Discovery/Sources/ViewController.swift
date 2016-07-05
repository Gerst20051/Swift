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

class ViewController: BaseViewController, MaterialSwitchDelegate, UITabBarDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {

    private var toolbar: Toolbar!
    private var bottomTabBar: BottomTabBar!
    private var searchBar: SearchBar!
    private var toolbarBackButton: MaterialButton!
    let realm = try! Realm()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var videoPlayerContainerView: UIView?
    var player: AVPlayer?
    let tableView = UITableView()
    let playlistController = PlaylistController()
    var playlists: Results<Playlist> {
        return realm.objects(Playlist).filter("items.@count > 0").sorted([ SortDescriptor(property: "favorite", ascending: false), "name" ])
    }
    var items: Results<StringObject> {
        return realm.objects(Playlist).filter(NSPredicate(format: "name = %@", selectedPlaylistName)).first!.items.sorted([ SortDescriptor(property: "favorite", ascending: false), "value" ])
    }
    var favorites: Results<StringObject> {
        return realm.objects(StringObject).filter("favorite == 1").sorted("value")
    }
    var searchItems: Results<StringObject> {
        if searchText.isEmpty {
            return realm.objects(StringObject).filter("value == ''") // return empty set
        } else {
            if favoritesMode { // search favorites
            } else if selectedPlaylistName.isNotEmpty { // search selected playlist
            } else { // search all items
            }
            return realm.objects(StringObject).filter(NSPredicate(format: "value CONTAINS %@", searchText)).sorted("value")
        }
    }
    var appName: String {
        return NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String
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
        let notificationCenter = NSNotificationCenter.defaultCenter()
        // notificationCenter.addObserver(self, selector: #selector(ViewController.playerDidFinishPlaying), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ViewController.playerPlaybackStalled), name: AVPlayerItemPlaybackStalledNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ViewController.deviceOrientationDidChange), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }

    func deviceOrientationDidChange() {
        addContraintsToViews()
    }

    func addSwipeGestureRecognizer() {
        for gesture in [ .Left, .Right, .Up ] as [UISwipeGestureRecognizerDirection] {
            let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.respondToSwipeGesture(_:)))
            swipeGesture.direction = gesture
            view.addGestureRecognizer(swipeGesture)
        }
    }

    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction as UISwipeGestureRecognizerDirection {
                case UISwipeGestureRecognizerDirection.Left, UISwipeGestureRecognizerDirection.Right:
                    if let videoPlayerContainerView = videoPlayerContainerView {
                        let videoPlayerContainsPoint = CGRectContainsPoint(videoPlayerContainerView.bounds, swipeGesture.locationInView(videoPlayerContainerView))
                        if videoPlayerContainsPoint {
                            removeVideoPlayerContainerView()
                        } else {
                            returnToListOfPlaylists()
                        }
                    } else if swipeGesture.direction == UISwipeGestureRecognizerDirection.Right {
                        returnToListOfPlaylists()
                    }
                case UISwipeGestureRecognizerDirection.Up:
                    if let videoPlayerContainerView = videoPlayerContainerView {
                        let videoPlayerContainsPoint = CGRectContainsPoint(videoPlayerContainerView.bounds, swipeGesture.locationInView(videoPlayerContainerView))
                        if videoPlayerContainsPoint {
                            // set video full screen
                        }
                    }
                default:
                    break
            }
        }
    }

    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        favoritesMode = item.title == "Starred"
    }

    func setupUI() {
        view.backgroundColor = MaterialColor.white
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
        toolbar.snp_remakeConstraints { (make) -> Void in
            make.bottom.equalTo(tableView.snp_top)
            make.height.equalTo(50.0)
            make.top.width.equalTo(view)
        }
    }

    func addSearchBarContraints() {
        searchBar.snp_remakeConstraints { (make) -> Void in
            make.bottom.equalTo(tableView.snp_top)
            make.height.equalTo(50.0)
            make.top.width.equalTo(view)
        }
    }

    func addTableViewContraints() {
        tableView.snp_remakeConstraints { (make) -> Void in
            make.bottom.equalTo(bottomTabBar.snp_top)
            if searchMode {
                make.top.equalTo(searchBar.snp_bottom)
            } else {
                make.top.equalTo(toolbar.snp_bottom)
            }
            make.width.equalTo(view)
        }
    }

    func addTabBarContraints() {
        bottomTabBar.snp_remakeConstraints { (make) -> Void in
            make.height.equalTo(50.0)
            make.top.equalTo(tableView.snp_bottom)
            make.width.equalTo(view)
        }
    }

    func addVideoPlayerContainerContraints() {
        videoPlayerContainerView?.snp_remakeConstraints { (make) -> Void in
            make.bottom.equalTo(bottomTabBar.snp_top)
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
                }.error { error in
                    switch error {
                        case PromiseError.ApiFailure(let error):
                            print("api failure => \(error)")
                        case PromiseError.InvalidPlaylist:
                            print("invalid playist")
                        default:
                            print("unhandled error => \(error)")
                    }
                    self.getLocalPlaylistJSON()
                }
            }
        }.always {
            self.hideLoader()
        }.error { error in
            switch error {
                case PromiseError.ApiFailure(let error):
                    print("api failure => \(error)")
                case PromiseError.InvalidPlaylistVersion:
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
        if let filePath = NSBundle.mainBundle().pathForResource("playlists", ofType: "json"), data = NSData(contentsOfFile: filePath) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
                parseLocalPlaylist(json as! [[String: AnyObject]])
            } catch let error {
                print("error parsing local json file => \(error)")
            }
        }
    }

    func parseLocalPlaylist(playlists: [[String: AnyObject]]) {
        playlistController.clearPlaylists()
        for playlist in playlists {
            if let playlistObject = Mapper<Playlist>().map(playlist) {
                playlistController.addPlaylist(playlistObject)
            }
        }
        scrollTableViewToTop()
        animateTableView()
    }

    func createToolbar() {
        toolbar = Toolbar()
        toolbar.backgroundColor = MaterialColor.teal.base
        toolbar.detailLabel.textColor = MaterialColor.white
        toolbar.titleLabel.textColor = MaterialColor.white
        toolbar.leftControls = []
        toolbar.rightControls = [ createToolbarSwitchControl(), createToolbarSearchButton() ]
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

    func createToolbarBackButton() -> MaterialButton {
        let backImage = MaterialIcon.cm.arrowBack
        let backButton = IconButton()
        backButton.pulseColor = MaterialColor.white
        backButton.tintColor = MaterialColor.white
        backButton.setImage(backImage, forState: .Normal)
        backButton.setImage(backImage, forState: .Highlighted)
        backButton.addTarget(self, action: #selector(handleToolbarBackButton), forControlEvents: .TouchUpInside)
        return backButton
    }

    func createToolbarSwitchControl() -> MaterialSwitch {
        let switchControl = MaterialSwitch(state: .Off, style: .LightContent, size: .Small)
        switchControl.delegate = self
        return switchControl
    }

    func createToolbarSearchButton() -> MaterialButton {
        let searchImage = MaterialIcon.cm.search
        let searchButton = IconButton()
        searchButton.pulseColor = MaterialColor.white
        searchButton.tintColor = MaterialColor.white
        searchButton.setImage(searchImage, forState: .Normal)
        searchButton.setImage(searchImage, forState: .Highlighted)
        searchButton.addTarget(self, action: #selector(handleToolbarSearchButton), forControlEvents: .TouchUpInside)
        return searchButton
    }

    func showToolbarBackButton() {
        toolbar.leftControls = [ toolbarBackButton ]
    }

    func hideToolbarBackButton() {
        toolbar.leftControls = []
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

    internal func materialSwitchStateChanged(control: MaterialSwitch) {
        shuffleMode = control.on
    }

    func createSearchBar() {
        searchBar = SearchBar()
        searchBar.backgroundColor = MaterialColor.teal.base
        searchBar.placeholderColor = MaterialColor.white
        searchBar.textColor = MaterialColor.white
        searchBar.tintColor = MaterialColor.white
        let image = MaterialIcon.cm.arrowBack
        let button = IconButton()
        button.pulseColor = MaterialColor.white
        button.tintColor = MaterialColor.white
        button.setImage(image, forState: .Normal)
        button.setImage(image, forState: .Highlighted)
        button.addTarget(self, action: #selector(handleSearchBackButton), forControlEvents: .TouchUpInside)
        searchBar.leftControls = [ button ]
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
        if let _ = tableView.superview, _ = bottomTabBar.superview {
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
        tableView.backgroundColor = MaterialColor.clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView(frame: CGRectZero)
        view.addSubview(tableView)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchMode ? searchItems.count : (favoritesMode ? favorites.count : (selectedPlaylistName.isEmpty ? playlists.count : items.count))
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.backgroundColor = MaterialColor.clear
        cell.removeMargins()
        cell.textLabel?.text = searchMode ? searchItems[row].value : (favoritesMode ? favorites[row].value : (selectedPlaylistName.isEmpty ? playlists[row].name : items[row].value))
        cell.textLabel?.textColor = MaterialColor.darkText.secondary
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
            let row = indexPath.row
            selectedPlaylistItem = searchMode ? searchItems[row].value! : (favoritesMode ? favorites[row].value! : items[row].value!)
            if let apiUrl = CloudUtils.getYouTubeApiUrl(selectedPlaylistItem) {
                print("apiUrl => \(apiUrl)")
                showLoader()
                Cloud.getYouTubeVideo(apiUrl).then { (videoId: String) -> Void in
                    print("youtube video id => \(videoId)")
                    self.loadVideo(videoId)
                }.error { error in
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

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let row = indexPath.row

        // let more = UITableViewRowAction(style: .Normal, title: "More") { action, index in
        //     print("more button tapped") // idk
        // }
        // more.backgroundColor = UIColor.lightGrayColor()

        let isFavorite = favoritesMode ? true : (searchMode ? searchItems[row].favorite : (selectedPlaylistName.isEmpty ? playlists[row].favorite : items[row].favorite))
        let favorite = UITableViewRowAction(style: .Normal, title: isFavorite ? "Unfavorite" : "Favorite") { action, index in
            print("(un)favorite button tapped")
            let row = index.row
            if self.selectedPlaylistName.isEmpty && !self.favoritesMode && !self.searchMode {
                self.playlistController.toggleFavorite(self.playlists[row])
            } else {
                self.playlistController.toggleFavorite(self.searchMode ? self.searchItems[row] : (self.favoritesMode ? self.favorites[row] : self.items[row]))
            }
            self.animateTableViewCell(tableView.cellForRowAtIndexPath(indexPath)!) { finished in
                self.animateTableView()
            }
        }
        favorite.backgroundColor = isFavorite ? MaterialColor.red.accent1 : MaterialColor.orange.accent1

        let share = UITableViewRowAction(style: .Normal, title: "Share") { action, index in
            print("share button tapped")
            let row = index.row
            self.handlePlaylistItemShare(self.searchMode ? self.searchItems[row].value! : (self.favoritesMode ? self.favorites[row].value! : self.items[row].value!))
        }
        share.backgroundColor = MaterialColor.blue.base

        var editActions: [UITableViewRowAction]? = []
        // editActions!.append(more)
        editActions!.append(favorite)
        if selectedPlaylistName.isNotEmpty {
            editActions!.append(share)
        }

        return editActions!.reverse()
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func animateTableViewCell(cell: UITableViewCell, completion: ((Bool) -> Void)?) {
        UIView.animateWithDuration(0.5, delay: 0.06, usingSpringWithDamping: 0.0, initialSpringVelocity: 0.0, options: [], animations: {
            cell.transform = CGAffineTransformMakeTranslation(-self.tableView.bounds.size.width, 0.0)
        }, completion: completion)
    }

    func animateTableView(directionLeft: Bool = false) {
        tableView.reloadData()
        for cell in tableView.visibleCells {
            cell.transform = CGAffineTransformMakeTranslation(directionLeft ? -tableView.bounds.size.width : tableView.bounds.size.width, 0.0)
            UIView.animateWithDuration(0.5, delay: 0.06, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.25, options: [], animations: {
                cell.transform = CGAffineTransformMakeTranslation(0.0, 0.0)
            }, completion: nil)
        }
    }

    func handlePlaylistItemShare(searchTerm: String) {
        if let apiUrl = CloudUtils.getYouTubeApiUrl(searchTerm) {
            showLoader()
            Cloud.getYouTubeVideo(apiUrl).then { (videoId: String) -> Void in
                print("sharing youtube video id => \(videoId)")
                UIPasteboard.generalPasteboard().string = "https://www.youtube.com/watch?v=\(videoId)"
                // NBMaterialToast.showWithText(self.view, text: "A Sharable Link To This Video Has Been Copied To Your Clipboard")
            }.always {
                self.hideLoader()
                self.tableView.setEditing(false, animated: true)
            }.error { error in
                print("error loading youtube video id => \(error)")
            }
        } else {
            print("error parsing youtube api url")
        }
    }

    func scrollTableViewToTop() {
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: Foundation.NSNotFound, inSection: 0), atScrollPosition: .Top, animated: false)
    }

    private func createTabBar() {
        bottomTabBar = BottomTabBar()
        bottomTabBar.backgroundColor = MaterialColor.grey.darken4
        bottomTabBar.delegate = self
        view.addSubview(bottomTabBar)

        let libraryItem = UITabBarItem(title: "Library", image: MaterialIcon.cm.audioLibrary, selectedImage: nil)
        libraryItem.setTitleColor(MaterialColor.grey.base, forState: .Normal)
        libraryItem.setTitleColor(MaterialColor.teal.base, forState: .Selected)

        let starredItem = UITabBarItem(title: "Starred", image: MaterialIcon.cm.star, selectedImage: nil)
        starredItem.setTitleColor(MaterialColor.grey.base, forState: .Normal)
        starredItem.setTitleColor(MaterialColor.teal.base, forState: .Selected)

        bottomTabBar.itemPositioning = .Automatic
        bottomTabBar.setItems([ libraryItem, starredItem ], animated: true)
        bottomTabBar.selectedItem = libraryItem
        bottomTabBar.tintColor = MaterialColor.teal.base
    }

    func createPinchGesture() {
        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.detectPinch(_:)))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }

    func detectPinch(sender: UIPinchGestureRecognizer) {
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
        videoPlayerContainerView!.hidden = true
        view.addSubview(videoPlayerContainerView!)
        addVideoPlayerContainerContraints()
    }

    func loadVideo(videoId: String) {
        createVideoContainerView()
        guard let containerView = videoPlayerContainerView else { return }
        XCDYouTubeClient.defaultClient().getVideoWithIdentifier(videoId) { [unowned containerView] (video: XCDYouTubeVideo?, error: NSError?) in
            if let streamURL = video?.streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? video?.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue] ?? video?.streamURLs[XCDYouTubeVideoQuality.Medium360.rawValue] ?? video?.streamURLs[XCDYouTubeVideoQuality.Small240.rawValue] {
                let playerItem = AVPlayerItem(URL: streamURL)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.playerDidFinishPlaying(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
                self.player = AVPlayer(playerItem: playerItem)
                // self.player.delegate = self
                let playerLayer = AVPlayerLayer()
                playerLayer.player = self.player
                playerLayer.frame = CGRect(origin: CGPointZero, size: containerView.frame.size)
                // playerLayer.backgroundColor = UIColor.blackColor().CGColor
                // playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                containerView.layer.addSublayer(playerLayer)
                self.player!.play()
                self.videoReceived() // need to add this to a new delegate method
            }
        }
    }

    func removeVideoPlayerContainerView() {
        videoPlayerContainerView?.hidden = true
        player?.pause() // how to stop video
        videoPlayerContainerView?.removeFromSuperview()
        videoPlayerContainerView = nil
        selectedPlaylistItem = ""
    }

    func videoReceived() {
        videoPlayerContainerView?.hidden = false
        hideLoader()
    }

    func playerDidFinishPlaying(notification: NSNotification) {
        print("playerDidFinishPlaying notification")
    }

    func playerDidFinishPlaying() {
        print("playerDidFinishPlaying")
    }

    func playerPlaybackStalled() {
        print("playerPlaybackStalled")
    }

    deinit {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        notificationCenter.removeObserver(self, name: AVPlayerItemPlaybackStalledNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
    }

}

extension ViewController: TextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        tableView.reloadData()
    }

    func textFieldDidEndEditing(textField: UITextField) {
        tableView.reloadData()
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        searchText = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        tableView.reloadData()
        return true
    }

    func textFieldShouldClear(textField: UITextField) -> Bool {
        tableView.reloadData()
        return true
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        searchBar.textField.resignFirstResponder()
        tableView.reloadData()
        return true
    }
}
