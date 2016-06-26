import AlamofireNetworkActivityIndicator
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow(frame: UIScreen.mainScreen().bounds)
    let nav = UINavigationController(rootViewController: ViewController())

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setupNetworkActivityIndicatorManager()
        setupNavigationController()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {}

    func applicationDidEnterBackground(application: UIApplication) {}

    func applicationWillEnterForeground(application: UIApplication) {}

    func applicationDidBecomeActive(application: UIApplication) {}

    func applicationWillTerminate(application: UIApplication) {}

    func setupNetworkActivityIndicatorManager() {
        NetworkActivityIndicatorManager.sharedManager.isEnabled = true
    }

    func setupNavigationController() {
        nav.navigationBarHidden = true
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }

}
