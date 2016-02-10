import Cocoa
import SnapKit

class MyViewController : BaseViewController {

    override func loadView() {
        let view = NSView(frame: NSMakeRect(0, 0, 100, 100))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.blueColor().CGColor
        view.layer?.borderColor = NSColor.blueColor().CGColor
        view.layer?.borderWidth = 2.0
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
        app.showMySecondViewController()
    }

}