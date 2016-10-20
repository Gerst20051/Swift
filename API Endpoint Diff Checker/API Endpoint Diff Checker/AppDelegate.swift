import Cocoa

@NSApplicationMain
class AppDelegate : NSObject, NSApplicationDelegate, NSWindowDelegate {

    @IBOutlet weak var window: NSWindow!
    let myViewController = MyViewController()
    let mySecondViewController = MySecondViewController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        showMyViewController()
    }

    func applicationWillTerminate(_ aNotification: Notification) {}

    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize { // TODO: Figure Out Why This Isn't Working...
        print("frameSize => \(frameSize)")
        return frameSize
    }

    func showMyViewController() {
        self.window.contentView = myViewController.view
    }

    func showMySecondViewController() {
        self.window.contentView = mySecondViewController.view
    }

}
