import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    let tokenViewController = TokenViewController()
    let mainViewController = MainViewController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        showTokenViewController()
    }

    func applicationWillTerminate(_ aNotification: Notification) {}

    func showTokenViewController() {
        window.contentView = tokenViewController.view
    }

    func showMainViewController() {
        window.contentView = mainViewController.view
    }

}
