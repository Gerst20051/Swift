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
// import YouTubePlayer

class ViewController: BaseViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource { // YouTubePlayerDelegate

    let realm = try! Realm()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    // var videoPlayer: YouTubePlayerView?
    var client = XCDYouTubeClient(languageIdentifier: "en")
    let tableView = UITableView()
    let playlistController = PlaylistController()
    var playlists: Results<Playlist> {
        return realm.objects(Playlist).filter("items.@count > 0").sorted([ "favorite", "name" ])
    }
    var items: Results<StringObject> {
        return realm.objects(Playlist).filter(NSPredicate(format: "name = %@", selectedPlaylistName)).first!.items.sorted([ "favorite", "value" ])
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.deviceOrientationDidChange), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }

    func deviceOrientationDidChange() {
        addTableViewContraints()
        // addVideoPlayerContraints()
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
                    returnToListOfPlaylists()
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
        // createVideoPlayer()
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
                Cloud.getYouTubeVideo(apiUrl).then { (videoId: String) -> Void in
                    print("youtube video id => \(videoId)")
                    self.showLoader()
                    // self.videoPlayer?.loadVideoID(videoId)
                    self.client.getVideoWithIdentifier(videoId) { (video: XCDYouTubeVideo?, error: NSError?) -> Void in
                        guard let video = video where error == nil else {
                            print("error => \(error?.localizedDescription)")
                            return
                        }
                        print("video => \(video)")
                    }
                    let videoPlayerViewController: XCDYouTubeVideoPlayerViewController = XCDYouTubeVideoPlayerViewController(videoIdentifier: videoId)
                    videoPlayerViewController.presentInView(self.view)
                    videoPlayerViewController.moviePlayer.play()
                }.error { error in
                    print("error loading youtube video id => \(error)")
                }
            } else {
                print("error parsing youtube api url")
            }
            if Defaults[.HelpOverlayShownForSpreadGesture] == false && false {
                Defaults[.HelpOverlayShownForSpreadGesture] = true
                showPopupView(image: "spread", title: "Spread Gesture", message: "A spread gesture will make your video fullscreen.")
            }
        }
    }

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let more = UITableViewRowAction(style: .Normal, title: "More") { action, index in
            print("more button tapped") // idk
        }
        more.backgroundColor = UIColor.lightGrayColor()

        let favorite = UITableViewRowAction(style: .Normal, title: "Favorite") { action, index in
            print("favorite button tapped") // add playlist or playlist item to favorites
        }
        favorite.backgroundColor = UIColor.orangeColor()

        let share = UITableViewRowAction(style: .Normal, title: "Share") { action, index in
            print("share button tapped") // load youtube link
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

    func scrollTableViewToTop() {
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: Foundation.NSNotFound, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
    }

    func createPinchGesture() {
        let gesture: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.detectPinch(_:)))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }

    func detectPinch(sender: UIPinchGestureRecognizer) {
        if sender.scale > 1.0 { // spread gesture
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

    // func createVideoPlayer() {
    //     videoPlayer = YouTubePlayerView(frame: CGRectMake(0.0, 0.0, 0.0, 0.0))
    //     videoPlayer!.delegate = self
    //     hideVideoPlayer()
    //     view.addSubview(videoPlayer!)
    //     addVideoPlayerContraints()
    // }

    // func addVideoPlayerContraints() {
    //     videoPlayer?.snp_remakeConstraints { (make) -> Void in
    //         make.bottom.equalTo(0.0)
    //         make.height.equalTo(100.0)
    //         make.width.equalTo(self.view.frame.size.width)
    //     }
    // }

    // func showVideoPlayer() {
    //     videoPlayer?.hidden = false
    // }

    // func hideVideoPlayer() {
    //     videoPlayer?.hidden = true
    // }

    // func playerReady(videoPlayer: YouTubePlayerView) {
    //     videoPlayer.play()
    // }

    // func playerStateChanged(videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
    //     print("playerStateChanged - playerState => \(playerState)")
    //     if [ .Unstarted, .Ended, .Paused ].contains(playerState) {
    //         hideLoader()
    //         if playerState == .Unstarted {
    //             NBMaterialToast.showWithText(view, text: "Restricted Video", duration: NBLunchDuration.LONG)
    //         }
    //     }
    // }

    // func playerQualityChanged(videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
    //     print("playerQualityChanged - playbackQuality => \(playbackQuality)")
    // }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
    }

}
