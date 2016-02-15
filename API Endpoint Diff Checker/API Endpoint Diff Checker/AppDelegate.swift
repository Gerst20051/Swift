import Cocoa

@NSApplicationMain
class AppDelegate : NSObject, NSApplicationDelegate, NSWindowDelegate {

    @IBOutlet weak var window: NSWindow!
    let myViewController = MyViewController()
    let mySecondViewController = MySecondViewController()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        showMyViewController()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
    }

    func windowWillResize(sender: NSWindow, toSize frameSize: NSSize) -> NSSize { // TODO: Figure Out Why This Isn't Working...
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
