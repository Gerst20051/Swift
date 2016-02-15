import Cocoa
import SnapKit

class MySecondViewController : BaseViewController {

    override func loadView() {
        let view = NSView(frame: NSMakeRect(0.0, 0.0, 50, 50))
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
            make.width.height.equalTo(50.0)
            make.center.equalTo(self.view)
        }
    }

    func myAction(sender: AnyObject) {
        ForrestUtils.runTest()
        app.showMyViewController()
    }

}