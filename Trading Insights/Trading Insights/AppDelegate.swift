import AKSideMenu
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AKSideMenuDelegate {

    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    let sideMenuViewController = AKSideMenu(contentViewController: CurrentIdeasViewController(), leftMenuViewController: LeftMenuViewController(), rightMenuViewController: UIViewController())
    let ideaRealmController = IdeaRealmController()
    let ideaIndicatorRealmController = IdeaIndicatorRealmController()
    let ideaSourceRealmController = IdeaSourceRealmController()
    let ideaSentimentRealmController = IdeaSentimentRealmController()
    let ideaHoldingDurationRealmController = IdeaHoldingDurationRealmController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        RealmUtils.logDebugInfo()
        if shouldPopulateRealmDatabase() {
            populateRealmDatabase()
        }
        setSideMenuViewController()
        setRootViewController()
        showSideMenu()
        return true
    }

    func setSideMenuViewController() {
        sideMenuViewController.backgroundImage = UIImage(named: AppImage.background)!
        sideMenuViewController.contentViewShadowColor = .black
        sideMenuViewController.contentViewShadowEnabled = true
        sideMenuViewController.contentViewShadowOffset = .zero
        sideMenuViewController.contentViewShadowOpacity = 0.6
        sideMenuViewController.contentViewShadowRadius = 12.0
        sideMenuViewController.delegate = self
        sideMenuViewController.menuPrefersStatusBarHidden = true
        sideMenuViewController.panFromEdgeZoneWidth = 40.0
    }

    func setRootViewController() {
        window?.rootViewController = sideMenuViewController
        window?.makeKeyAndVisible()
    }

    func shouldPopulateRealmDatabase() -> Bool {
        return !ideaIndicatorRealmController.isPopulated() || !ideaSourceRealmController.isPopulated() || !ideaSentimentRealmController.isPopulated() || !ideaHoldingDurationRealmController.isPopulated()
    }

    func populateRealmDatabase() {
        ideaIndicatorRealmController.populate()
        ideaSourceRealmController.populate()
        ideaSentimentRealmController.populate()
        ideaHoldingDurationRealmController.populate()
    }

    func showSideMenu() {
        sideMenuViewController.presentLeftMenuViewController()
    }

}
