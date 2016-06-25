import Alamofire
import AlamofireObjectMapper
import PromiseKit
import RealmSwift
import SnapKit
import UIKit

class ViewController: BaseViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {

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
        view.backgroundColor = UIColor(red: 216.0 / 255.0, green: 53.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0)
        loadPlaylistData()
        createTableView()
        createPinchGesture()
        // showNavigationButton()
    }

    func showNavigationButton() {
        let button: UIButton = UIButton()
        button.backgroundColor = UIColor.blackColor()
        button.setTitle("Next", forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(self.buttonClicked), forControlEvents: .TouchUpInside)
        view.addSubview(button)
        button.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(50.0)
            make.width.equalTo(100.0)
            make.center.equalTo(self.view)
        }
    }

    func buttonClicked() {
        print("Next Button Clicked")
        app.nav.pushViewController(SecondViewController(), animated: true)
    }

    func loadPlaylistData() {
        downloadPlaylistVersion().then { currentPlaylistVersion -> Void in
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let playlistVersion = userDefaults.integerForKey(UserDefaultsKey.PlaylistVersion)
            if playlistVersion == currentPlaylistVersion && false {
                print("playlist is up-to-date")
            } else {
                self.downloadPlaylistJSON().then { Void -> Void in
                    userDefaults.setInteger(currentPlaylistVersion, forKey: UserDefaultsKey.PlaylistVersion)
                    self.tableView.reloadData()
                    return
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
        view.addSubview(tableView)
        tableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(20.0)
            make.height.equalTo(self.view).offset(-20.0)
            make.width.equalTo(self.view)
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedPlaylistName.isEmpty {
            return playlists.count
        } else {
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
        } else {
            print("item name => \(items[indexPath.row].value)")
        }
    }

    func createPinchGesture() {
        let gesture: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.detectPinch(_:)))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }

    func detectPinch(sender: UIPinchGestureRecognizer) {
        selectedPlaylistName = ""
    }

}
