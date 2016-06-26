import Alamofire
import AlamofireObjectMapper
import NMPopUpViewSwift
import NVActivityIndicatorView
import PromiseKit
import RealmSwift
import SnapKit
import UIKit

class ViewController: BaseViewController, NVActivityIndicatorViewable, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {

    let realm = try! Realm()
    let playlistController = PlaylistController()
    var playlists: Results<Playlist> {
        get {
            return realm.objects(Playlist).filter("items.@count > 0")
        }
    }
    var items: List<StringObject> {
        get {
            return realm.objects(Playlist).filter(NSPredicate(format: "name = %@", selectedPlaylistName)).first!.items
        }
    }
    let tableView = UITableView()
    var selectedPlaylistName: String = "" {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Realm File Location => \(Realm.Configuration.defaultConfiguration.fileURL)")
        setupUI()
    }

    func setupUI() {
        view.backgroundColor = AppColor.AppIconRed
        loadPlaylistData()
        createTableView()
        createPinchGesture()
    }

    func loadPlaylistData() {
        showLoader()
        downloadPlaylistVersion().then { currentPlaylistVersion -> Void in
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let playlistVersion = userDefaults.integerForKey(UserDefaultsKey.PlaylistVersion)
            if playlistVersion == currentPlaylistVersion && false {
                print("playlist is up-to-date")
            } else {
                self.showLoader()
                self.downloadPlaylistJSON().then { Void -> Void in
                    userDefaults.setInteger(currentPlaylistVersion, forKey: UserDefaultsKey.PlaylistVersion)
                    self.tableView.reloadData()
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
        }
    }

    func downloadPlaylistVersion() -> Promise<Int> {
        let versionUrl = "https://gist.githubusercontent.com/Gerst20051/d8ff84358883664c5c07f0748fedbef4/raw/version.txt2"
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
        let playlistUrl = "https://gist.githubusercontent.com/Gerst20051/d8ff84358883664c5c07f0748fedbef4/raw/playlists.json2"
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
        if let filePath = NSBundle.mainBundle().pathForResource("playlists", ofType: "json"), data = NSData(contentsOfFile: filePath) {
            do {
                _ = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
            } catch let error {
                print("error parsing local json file => \(error)")
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
        tableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(20.0)
            make.height.equalTo(self.view).offset(-20.0)
            make.width.equalTo(self.view)
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedPlaylistName.isEmpty {
            print("count => \(playlists.count)")
            return playlists.count
        } else {
            print("count => \(items.count)")
            return items.count
        }
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
            showPopupView(image: "pinch", title: "Pinch Gesture", message: "A pinch gesture will take you back to your playlists.")
        } else {
            print("item name => \(items[indexPath.row].value)")
            showPopupView(image: "spread", title: "Spread Gesture", message: "A spread gesture will make your video fullscreen.")
        }
    }

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let more = UITableViewRowAction(style: .Normal, title: "More") { action, index in
            print("more button tapped")
        }
        more.backgroundColor = UIColor.lightGrayColor()

        let favorite = UITableViewRowAction(style: .Normal, title: "Favorite") { action, index in
            print("favorite button tapped")
        }
        favorite.backgroundColor = UIColor.orangeColor()

        let share = UITableViewRowAction(style: .Normal, title: "Share") { action, index in
            print("share button tapped")
        }
        share.backgroundColor = UIColor.blueColor()

        return [ more, favorite, share ].reverse()
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {}

    func createPinchGesture() {
        let gesture: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.detectPinch(_:)))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }

    func detectPinch(sender: UIPinchGestureRecognizer) {
        if sender.scale > 1.0 {
            print("spread gesture")
        } else {
            print("pinch gesture")
            if selectedPlaylistName.isNotEmpty {
                selectedPlaylistName = ""
            }
        }
    }

}
