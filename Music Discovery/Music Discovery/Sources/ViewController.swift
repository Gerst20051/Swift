import Alamofire
import AlamofireObjectMapper
import NMPopUpViewSwift
import NVActivityIndicatorView
import ObjectMapper
import PromiseKit
import RealmSwift
import SnapKit
import UIKit
import XCDYouTubeKit
import YouTubePlayer

class ViewController: BaseViewController, YouTubePlayerDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {

    let realm = try! Realm()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var videoPlayer: YouTubePlayerView?
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
    var hasShownPinchGesture = false
    var hasShownSpreadGesture = false

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Realm File Location => \(Realm.Configuration.defaultConfiguration.fileURL)")
        monitorDeviceOrientationChange()
        setupUI()
    }

    func monitorDeviceOrientationChange() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.deviceOrientationDidChange), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }

    func deviceOrientationDidChange() {
        addTableViewContraints()
        addVideoPlayerContraints()
    }

    func setupUI() {
        view.backgroundColor = AppColor.AppIconRed
        loadPlaylistData()
        createTableView()
        createPinchGesture()
        createVideoPlayer()
    }

    func loadPlaylistData() {
        showLoader()
        downloadPlaylistVersion().then { currentPlaylistVersion -> Void in
            if self.getPlaylistVersion() == currentPlaylistVersion {
                print("playlist is up-to-date")
            } else {
                self.showLoader()
                self.downloadPlaylistJSON().then { Void -> Void in
                    self.userDefaults.setInteger(currentPlaylistVersion, forKey: UserDefaultsKey.PlaylistVersion)
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
        return userDefaults.integerForKey(UserDefaultsKey.PlaylistVersion)
    }

    func downloadPlaylistVersion() -> Promise<Int> {
        let versionUrl = "https://gist.githubusercontent.com/Gerst20051/d8ff84358883664c5c07f0748fedbef4/raw/version.txt"
        return Promise { fulfill, reject in
            Alamofire.request(.GET, versionUrl).validate().responseString { response in
                if response.result.isSuccess {
                    if let resultString = response.result.value, playlistVersion = Int(resultString) {
                        fulfill(playlistVersion)
                    } else {
                        reject(PromiseError.InvalidPlaylistVersion())
                    }
                } else {
                    reject(PromiseError.ApiFailure(response.result.error))
                }
            }
        }
    }

    func downloadPlaylistJSON() -> Promise<Void> {
        let playlistUrl = "https://gist.githubusercontent.com/Gerst20051/d8ff84358883664c5c07f0748fedbef4/raw/playlists.json"
        return Promise<Void> { fulfill, reject in
            Alamofire.request(.GET, playlistUrl).validate().responseArray { (response: Response<[Playlist], NSError>) in
                if response.result.isSuccess {
                    if let playlists = response.result.value {
                        self.playlistController.clearPlaylists()
                        for playlist in playlists {
                            self.playlistController.addPlaylist(playlist)
                        }
                        fulfill()
                    } else {
                        reject(PromiseError.InvalidPlaylist())
                    }
                } else {
                    reject(PromiseError.ApiFailure(response.result.error))
                }
            }
        }
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

    func getYouTubeApiUrl(query: String) -> String? {
        if let query = query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()), fields = "items/id/videoId".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
            let results = 1, key = "AIzaSyBSXDaYvJGY4dbLFDF66NrSrlUYH9rVZ9A"
            return "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=\(results)&q=\(query)&type=video&videoEmbeddable=true&videoSyndicated=true&fields=\(fields)&key=\(key)"
        }
        return nil
    }

    func getYouTubeVideo(url: String) -> Promise<String> {
        return Promise<String> { fulfill, reject in
            Alamofire.request(.GET, url).responseObject { (response: Response<YouTubeVideoSearchResults, NSError>) in
                if response.result.isSuccess {
                    if let results = response.result.value, result = results.items?.first, videoId = result.id?.videoId {
                        fulfill(videoId) // maybe return an array of videoIds since so many videos are restricted on certain sites
                    } else {
                        reject(PromiseError.NoYouTubeSearchResults())
                    }
                } else {
                    reject(PromiseError.ApiFailure(response.result.error))
                }
            }.responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }
        }
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
            if hasShownPinchGesture == false {
                hasShownPinchGesture = true
                showPopupView(image: "pinch", title: "Pinch Gesture", message: "A pinch gesture will take you back to your playlists.")
            }
        } else {
            selectedPlaylistItem = items[indexPath.row].value!
            if let apiUrl = getYouTubeApiUrl(selectedPlaylistItem) {
                print("apiUrl => \(apiUrl)")
                getYouTubeVideo(apiUrl).then { (videoId: String) -> Void in
                    print("youtube video id => \(videoId)")
                    self.showLoader()
                    self.videoPlayer?.loadVideoID(videoId)
                    // self.client.getVideoWithIdentifier(videoId) { (video: XCDYouTubeVideo?, error: NSError?) -> Void in
                    //     video
                    //     error?.localizedDescription
                    // }
                }.error { error in
                    print("error loading youtube video id => \(error)")
                }
            } else {
                print("error parsing youtube api url")
            }
            if hasShownSpreadGesture == false && false {
                hasShownSpreadGesture = true
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
            hideVideoPlayer()
            if selectedPlaylistName.isNotEmpty {
                selectedPlaylistName = ""
            }
        }
    }

    func createVideoPlayer() {
        videoPlayer = YouTubePlayerView(frame: CGRectMake(0.0, 0.0, 0.0, 0.0))
        videoPlayer!.delegate = self
        hideVideoPlayer()
        view.addSubview(videoPlayer!)
        addVideoPlayerContraints()
    }

    func addVideoPlayerContraints() {
        videoPlayer?.snp_remakeConstraints { (make) -> Void in
            make.bottom.equalTo(0.0)
            make.height.equalTo(100.0)
            make.width.equalTo(self.view.frame.size.width)
        }
    }

    func showVideoPlayer() {
        videoPlayer?.hidden = false
    }

    func hideVideoPlayer() {
        videoPlayer?.hidden = true
    }

    func playerReady(videoPlayer: YouTubePlayerView) {
        videoPlayer.play()
    }

    func playerStateChanged(videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        print("playerStateChanged - playerState => \(playerState)")
        if [ .Unstarted, .Ended, .Paused ].contains(playerState) {
            hideLoader()
            // show dialog explaining that the video is restricted...
        }
    }

    func playerQualityChanged(videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
        print("playerQualityChanged - playbackQuality => \(playbackQuality)")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
    }

}
