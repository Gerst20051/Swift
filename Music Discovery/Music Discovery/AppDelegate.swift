import AlamofireNetworkActivityIndicator
import SwiftyTimer
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow(frame: UIScreen.mainScreen().bounds)
    var nav: UINavigationController!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setupSplashScreen()
        setupNetworkActivityIndicatorManager()
        setupNavigationController()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {}

    func applicationDidEnterBackground(application: UIApplication) {}

    func applicationWillEnterForeground(application: UIApplication) {}

    func applicationDidBecomeActive(application: UIApplication) {}

    func applicationWillTerminate(application: UIApplication) {}

    func setupSplashScreen() {
        if let splashScreen = NSBundle.mainBundle().loadNibNamed("SplashScreen", owner: self, options: nil).first as? SplashScreenViewController {
            nav = UINavigationController(rootViewController: splashScreen)
            NSTimer.after(2.5.seconds) {
                self.nav.setViewControllers([ ViewController() ], animated: true)
            }
        } else {
            nav = UINavigationController(rootViewController: ViewController())
        }
    }

    func setupNetworkActivityIndicatorManager() {
        NetworkActivityIndicatorManager.sharedManager.isEnabled = true
    }

    func setupNavigationController() {
        nav.navigationBarHidden = true
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }

}

class SplashScreenViewController: UIViewController {}
