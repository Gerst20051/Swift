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
    let realm = try! Realm()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var videoPlayerContainerView: UIView?
    var videoPlayerViewController: XCDYouTubeVideoPlayerViewController!
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
    var appName: String {
        return NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String
    }
    var selectedPlaylistName: String = "" {
        didSet {
            setToolbarTitle()
            scrollTableViewToTop()
            animateTableView(selectedPlaylistName == "")
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

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Realm File Location => \(Realm.Configuration.defaultConfiguration.fileURL)")
        monitorDeviceOrientationChange()
        addSwipeGestureRecognizer()
        setupUI()
    }

    func monitorDeviceOrientationChange() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(ViewController.playbackStateChanged), name: MPMoviePlayerPlaybackStateDidChangeNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ViewController.deviceOrientationDidChange), name: UIDeviceOrientationDidChangeNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ViewController.videoReceived), name: XCDYouTubeVideoPlayerViewControllerDidReceiveVideoNotification, object: nil)
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
                            videoPlayerViewController?.moviePlayer.setFullscreen(true, animated: true)
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
        createTableView()
        createTabBar()
        addContraintsToViews()
        createPinchGesture()
        createVideoContainerView()
        loadPlaylistData()
    }

    func addContraintsToViews() {
        addToolbarContraints()
        // addSearchBarContraints()
        addTableViewContraints()
        addTabBarContraints()
        addVideoPlayerContainerContraints()
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
            make.top.equalTo(toolbar.snp_bottom)
            // make.top.equalTo(searchBar.snp_bottom)
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
        toolbar.rightControls = [ createToolbarSwitchControl(), createToolbarSearchButton() ]
        view.addSubview(toolbar)
        setToolbarTitle()
        setToolbarSubtitle()
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

    func handleToolbarSearchButton() {
        print("show search toolbar")
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
        // view.addSubview(searchBar)
        let image = MaterialIcon.cm.moreVertical
        let moreButton = IconButton()
        moreButton.pulseColor = MaterialColor.grey.base
        moreButton.tintColor = MaterialColor.grey.darken4
        moreButton.setImage(image, forState: .Normal)
        moreButton.setImage(image, forState: .Highlighted)
        searchBar.leftControls = [ moreButton ]
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
        return favoritesMode ? favorites.count : (selectedPlaylistName.isEmpty ? playlists.count : items.count)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.backgroundColor = MaterialColor.clear
        cell.removeMargins()
        cell.textLabel?.text = favoritesMode ? favorites[indexPath.row].value : (selectedPlaylistName.isEmpty ? playlists[indexPath.row].name : items[indexPath.row].value)
        cell.textLabel?.textColor = MaterialColor.darkText.secondary
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if selectedPlaylistName.isEmpty && !favoritesMode {
            selectedPlaylistName = playlists[indexPath.row].name
            if Defaults[.HelpOverlayShownForPinchGesture] == false {
                Defaults[.HelpOverlayShownForPinchGesture] = true
                showPopupView(image: "pinch", title: "Pinch Gesture", message: "Pinch or swipe right to return to your playlists.")
            }
        } else {
            selectedPlaylistItem = favoritesMode ? favorites[indexPath.row].value! : items[indexPath.row].value!
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
        // let more = UITableViewRowAction(style: .Normal, title: "More") { action, index in
        //     print("more button tapped") // idk
        // }
        // more.backgroundColor = UIColor.lightGrayColor()

        let isFavorite = favoritesMode ? true : (selectedPlaylistName.isEmpty ? playlists[indexPath.row].favorite : items[indexPath.row].favorite)
        let favorite = UITableViewRowAction(style: .Normal, title: isFavorite ? "Unfavorite" : "Favorite") { action, index in
            print("(un)favorite button tapped")
            if self.selectedPlaylistName.isEmpty && !self.favoritesMode {
                self.playlistController.toggleFavorite(self.playlists[index.row])
            } else {
                self.playlistController.toggleFavorite(self.favoritesMode ? self.favorites[index.row] : self.items[index.row])
            }
            self.animateTableViewCell(tableView.cellForRowAtIndexPath(indexPath)!) { finished in
                self.animateTableView()
            }
        }
        favorite.backgroundColor = isFavorite ? MaterialColor.red.accent1 : MaterialColor.orange.accent1

        let share = UITableViewRowAction(style: .Normal, title: "Share") { action, index in
            print("share button tapped")
            self.handlePlaylistItemShare(self.favoritesMode ? self.favorites[index.row].value! : self.items[index.row].value!)
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
            videoPlayerViewController?.moviePlayer.setFullscreen(true, animated: true)
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
        videoPlayerViewController?.moviePlayer.stop()
        videoPlayerViewController?.view.removeFromSuperview()
        videoPlayerViewController = XCDYouTubeVideoPlayerViewController(videoIdentifier: videoId)
        videoPlayerViewController.presentInView(containerView)
        videoPlayerViewController.moviePlayer.play()
        UIApplication.sharedApplication().statusBarHidden = true
    }

    func removeVideoPlayerContainerView() {
        videoPlayerContainerView?.hidden = true
        videoPlayerViewController?.view.hidden = true
        videoPlayerViewController?.moviePlayer.stop()
        videoPlayerViewController?.view.removeFromSuperview()
        videoPlayerContainerView?.removeFromSuperview()
        videoPlayerContainerView = nil
        selectedPlaylistItem = ""
        UIApplication.sharedApplication().statusBarHidden = true
    }

    func videoReceived() {
        videoPlayerContainerView?.hidden = false
        hideLoader()
    }

    func playbackStateChanged() {
        print("playbackState => \(videoPlayerViewController?.moviePlayer.playbackState.rawValue)") // hide video when it reaches the end or select next video if in shuffle mode
    }

    deinit {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: MPMoviePlayerPlaybackStateDidChangeNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
        notificationCenter.removeObserver(self, name: XCDYouTubeVideoPlayerViewControllerDidReceiveVideoNotification, object: nil)
    }

}
