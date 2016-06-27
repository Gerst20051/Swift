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

class ViewController: BaseViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {

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
    var selectedPlaylistName: String = "" {
        didSet {
            tableView.reloadData()
            scrollTableViewToTop()
        }
    }
    var selectedPlaylistItem: String = ""

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
        addTableViewContraints()
        addVideoPlayerContainerContraints()
    }

    func addSwipeGestureRecognizer() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.respondToSwipeGesture(_:)))
        swipeGesture.direction = .Right
        view.addGestureRecognizer(swipeGesture)
    }

    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
                case UISwipeGestureRecognizerDirection.Right:
                    if let videoPlayerContainerView = videoPlayerContainerView {
                        let videoPlayerContainsPoint = CGRectContainsPoint(videoPlayerContainerView.bounds, swipeGesture.locationInView(videoPlayerContainerView))
                        if videoPlayerContainsPoint {
                            removeVideoPlayerContainerView()
                        } else {
                            returnToListOfPlaylists()
                        }
                    } else {
                        returnToListOfPlaylists()
                    }
                default:
                    break
            }
        }
    }

    func setupUI() {
        view.backgroundColor = Color.AppIconRed
        loadPlaylistData()
        createTableView()
        createPinchGesture()
        createVideoContainerView()
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
                    self.tableView.reloadData()
                    self.scrollTableViewToTop()
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
        tableView.reloadData()
        scrollTableViewToTop()
    }

    func createTableView() {
        tableView.backgroundColor = UIColor.clearColor()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView(frame: CGRectZero)
        view.addSubview(tableView)
        addTableViewContraints()
    }

    func addTableViewContraints() {
        tableView.snp_remakeConstraints { (make) -> Void in
            let statusBarHeight: CGFloat = UIDevice.currentDevice().orientation.isLandscape ? 0.0 : 20.0
            make.top.equalTo(statusBarHeight)
            make.height.equalTo(self.view).offset(-statusBarHeight)
            make.width.equalTo(self.view)
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedPlaylistName.isEmpty ? playlists.count : items.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.backgroundColor = UIColor.clearColor()
        cell.removeMargins()
        cell.textLabel?.text = selectedPlaylistName.isEmpty ? playlists[indexPath.row].name : items[indexPath.row].value
        cell.textLabel?.textColor = UIColor.whiteColor()
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if selectedPlaylistName.isEmpty {
            selectedPlaylistName = playlists[indexPath.row].name
            if Defaults[.HelpOverlayShownForPinchGesture] == false {
                Defaults[.HelpOverlayShownForPinchGesture] = true
                showPopupView(image: "pinch", title: "Pinch Gesture", message: "Pinch or swipe right to return to your playlists.")
            }
        } else {
            selectedPlaylistItem = items[indexPath.row].value!
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

        let isFavorite = selectedPlaylistName.isEmpty ? playlists[indexPath.row].favorite : items[indexPath.row].favorite
        let favorite = UITableViewRowAction(style: .Normal, title: isFavorite ? "Unfavorite" : "Favorite") { action, index in
            print("(un)favorite button tapped")
            if self.selectedPlaylistName.isEmpty {
                self.playlistController.toggleFavorite(self.playlists[index.row])
            } else {
                self.playlistController.toggleFavorite(self.items[index.row])
            }
            self.tableView.reloadData()
        }
        favorite.backgroundColor = UIColor.orangeColor()

        let share = UITableViewRowAction(style: .Normal, title: "Share") { action, index in
            print("share button tapped")
            self.handlePlaylistItemShare(self.items[index.row].value!)
        }
        share.backgroundColor = UIColor.blueColor()

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

    func handlePlaylistItemShare(searchTerm: String) {
        if let apiUrl = CloudUtils.getYouTubeApiUrl(searchTerm) {
            showLoader()
            Cloud.getYouTubeVideo(apiUrl).then { (videoId: String) -> Void in
                print("sharing youtube video id => \(videoId)")
                UIPasteboard.generalPasteboard().string = "https://www.youtube.com/watch?v=\(videoId)"
                NBMaterialToast.showWithText(self.view, text: "A Sharable Link To This Video Has Been Copied To Your Clipboard")
            }.always {
                self.hideLoader()
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

    func addVideoPlayerContainerContraints() {
        videoPlayerContainerView?.snp_remakeConstraints { (make) -> Void in
            make.bottom.right.equalTo(0.0)
            make.height.equalTo(140.0)
            make.width.equalTo(200.0)
        }
    }

    func loadVideo(videoId: String) {
        createVideoContainerView()
        guard let containerView = videoPlayerContainerView else { return }
        videoPlayerViewController?.moviePlayer.stop()
        videoPlayerViewController?.view.removeFromSuperview()
        videoPlayerViewController = XCDYouTubeVideoPlayerViewController(videoIdentifier: videoId)
        videoPlayerViewController.presentInView(containerView)
        videoPlayerViewController.moviePlayer.play()
    }

    func removeVideoPlayerContainerView() {
        videoPlayerContainerView?.hidden = true
        videoPlayerViewController?.view.hidden = true
        videoPlayerViewController?.moviePlayer.stop()
        videoPlayerViewController?.view.removeFromSuperview()
        videoPlayerContainerView?.removeFromSuperview()
        videoPlayerContainerView = nil
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
