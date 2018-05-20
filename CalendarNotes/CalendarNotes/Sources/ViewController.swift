import UIKit

class ViewController: BaseViewController {

    // fileprivate var toolbar: Toolbar!
    // fileprivate var searchBar: SearchBar!
    // fileprivate var toolbarBackButton: IconButton!
    // fileprivate var toolbarSettingsButton: IconButton!
    // var bottomTabBar: BottomTabBar!
    // let realm = try! Realm()
    // let tableView = UITableView()
    // var appName: String {
    //     return Bundle.main.infoDictionary!["CFBundleName"] as! String
    // }

    override func viewDidLoad() {
        super.viewDidLoad()
        RealmUtils.logDebugInfo()
        setupInterface()
    }

    func setupInterface() {
        view.backgroundColor = .white
        // createToolbar()
        // createSearchBar()
        // showToolbarOrSearchBar()
        // createTableView()
        // createTabBar()
        // addContraintsToViews()
        // search()
    }

    // func search() {
    //     _ = Cloud.searchPodcasts(keywords: "Comedy").then { podcasts -> Void in
    //         for podcast in podcasts {
    //             print("\(podcast.title!) - \(podcast.url!)")
    //         }
    //     }.catch { error in
    //         print("error => \(error)")
    //     }
    // }

}
