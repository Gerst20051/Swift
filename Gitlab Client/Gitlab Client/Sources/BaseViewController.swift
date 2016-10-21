import Cocoa

class BaseViewController: NSViewController {

    var app: AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }

}
