import AlamofireNetworkActivityIndicator
import SwiftyTimer
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    var nav: UINavigationController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupSplashScreen()
        setupNetworkActivityIndicatorManager()
        setupNavigationController()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}

    func setupSplashScreen() {
        if let splashScreen = Bundle.main.loadNibNamed("SplashScreen", owner: self, options: nil)?.first as? SplashScreenViewController {
            nav = UINavigationController(rootViewController: splashScreen)
            Timer.after(2.seconds) {
                self.nav.setViewControllers([ ViewController() ], animated: true)
            }
        } else {
            nav = UINavigationController(rootViewController: ViewController())
        }
    }

    func setupNetworkActivityIndicatorManager() {
        NetworkActivityIndicatorManager.shared.isEnabled = true
    }

    func setupNavigationController() {
        nav.isNavigationBarHidden = true
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }

}
