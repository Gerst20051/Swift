import Cocoa

class BaseViewController : NSViewController {

    var app: AppDelegate {
        return NSApplication.sharedApplication().delegate as! AppDelegate
    }

}
