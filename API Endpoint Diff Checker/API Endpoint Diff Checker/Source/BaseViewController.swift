import Cocoa

class BaseViewController : NSViewController {

    var app: AppDelegate {
        get {
            return NSApplication.sharedApplication().delegate as! AppDelegate
        }
    }

}
