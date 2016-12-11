import AKSideMenu
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AKSideMenuDelegate {

    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    var sideMenuViewController: AKSideMenu?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        RealmUtils.logDebugInfo()
        setSideMenuViewController()
        setRootViewController()
        showSideMenu()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}

    func setSideMenuViewController() {
        sideMenuViewController = AKSideMenu(contentViewController: CurrentIdeasViewController(), leftMenuViewController: LeftMenuViewController(), rightMenuViewController: UIViewController())
        sideMenuViewController!.backgroundImage = UIImage(named: "background")!
        sideMenuViewController!.contentViewShadowColor = .black
        sideMenuViewController!.contentViewShadowEnabled = true
        sideMenuViewController!.contentViewShadowOffset = .zero
        sideMenuViewController!.contentViewShadowOpacity = 0.6
        sideMenuViewController!.contentViewShadowRadius = 12.0
        sideMenuViewController!.delegate = self
        sideMenuViewController!.menuPrefersStatusBarHidden = true
        sideMenuViewController!.panFromEdgeZoneWidth = 40.0
    }

    func setRootViewController() {
        window?.rootViewController = sideMenuViewController
        window?.makeKeyAndVisible()
    }

    func showSideMenu() {
        sideMenuViewController!.presentLeftMenuViewController()
    }

    open func sideMenu(_ sideMenu: AKSideMenu, willShowMenuViewController menuViewController: UIViewController) {
        print("willShowMenuViewController")
    }

    open func sideMenu(_ sideMenu: AKSideMenu, didShowMenuViewController menuViewController: UIViewController) {
        print("didShowMenuViewController")
    }

    open func sideMenu(_ sideMenu: AKSideMenu, willHideMenuViewController menuViewController: UIViewController) {
        print("willHideMenuViewController")
    }

    open func sideMenu(_ sideMenu: AKSideMenu, didHideMenuViewController menuViewController: UIViewController) {
        print("didHideMenuViewController")
    }

}
