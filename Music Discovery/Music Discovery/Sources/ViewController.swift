import Alamofire
import AlamofireObjectMapper
import PromiseKit
import RealmSwift
import SnapKit
import UIKit

class ViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        view.backgroundColor = UIColor.redColor()
        showNavigationButton()
        print("Realm File Location => \(Realm.Configuration.defaultConfiguration.fileURL)")
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
        loadPlaylistData()
        app.nav.pushViewController(SecondViewController(), animated: true)
    }

    func loadPlaylistData() {
        downloadPlaylistVersion().then { currentPlaylistVersion -> Void in
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let playlistVersion = userDefaults.integerForKey(UserDefaultsKey.PlaylistVersion)
            if playlistVersion == currentPlaylistVersion && false {
                print("playlist is up-to-date")
            } else {
                self.downloadPlaylistJSON().then {
                    userDefaults.setInteger(currentPlaylistVersion, forKey: UserDefaultsKey.PlaylistVersion)
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
                        let realm = try! Realm()
                        try! realm.write {
                            realm.deleteAll()
                            for playlist in playlists {
                                realm.add(playlist, update: true)
                            }
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

}
