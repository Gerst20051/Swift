import Cocoa

extension NSViewController {

    func getAppDelegate() -> AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }

}
