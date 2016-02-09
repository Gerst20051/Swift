import Cocoa

extension NSViewController {
    func getAppDelegate() -> AppDelegate {
        return NSApplication.sharedApplication().delegate as! AppDelegate
    }
}
