import Cocoa
import Forrest
import SnapKit

class MySecondViewController : NSViewController {
    override func loadView() {
        let view = NSView(frame: NSMakeRect(0, 0, 50, 50))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.greenColor().CGColor
        view.layer?.borderWidth = 2.0
        view.layer?.borderColor = NSColor.greenColor().CGColor
        self.view = view

        let button = NSButton()
        button.action = "myAction:"
        button.target = self
        self.view.addSubview(button)

        button.snp_makeConstraints { (make) -> Void in
            make.width.height.equalTo(50)
            make.center.equalTo(self.view)
        }
    }

    func myAction(sender: AnyObject) {
        testForrest()
        getAppDelegate().showMyViewController()
    }

    func testForrest() {
        let forrest = Forrest()
        let pwd = forrest.run("pwd").stdout // Get Current Directory
        print("pwd => \(pwd)")
        let swiftFiles = forrest.run("ls -la | grep swift").stdout // Piped Commands
        print("swiftFiles => \(swiftFiles)")
    }
}