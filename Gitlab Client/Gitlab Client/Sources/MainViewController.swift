import Cocoa
import SnapKit

class MainViewController : BaseViewController {

    override func loadView() {
        let view = NSView(frame: NSMakeRect(0.0, 0.0, 50.0, 50.0))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.blue().cgColor
        view.layer?.borderColor = NSColor.blue().cgColor
        view.layer?.borderWidth = 2.0
        self.view = view

        let button = NSButton()
        button.action = #selector(MainViewController.myAction)
        button.target = self
        self.view.addSubview(button)

        button.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(50.0)
            make.centerX.centerY.equalTo(self.view) // center is missing in swift 3 branch?
        }
    }

    func myAction(sender: AnyObject) {
        app.showTokenViewController()
    }

}
