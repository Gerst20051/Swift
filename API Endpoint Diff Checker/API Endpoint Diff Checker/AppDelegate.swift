import Cocoa

@NSApplicationMain
class AppDelegate : NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    let myViewController = MyViewController()
    let mySecondViewController = MySecondViewController()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        showMyViewController()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
    }

    func showMyViewController() {
        self.window.contentView = myViewController.view
    }

    func showMySecondViewController() {
        self.window.contentView = mySecondViewController.view
    }

}
