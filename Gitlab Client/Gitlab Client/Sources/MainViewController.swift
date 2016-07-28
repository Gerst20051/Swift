import Cocoa
import SnapKit
import SwiftyUserDefaults

class MainViewController : BaseViewController {

    let label = NSTextField()

    override func loadView() {
        createView()
        buildUI()
        makeConstraints()
    }

    func createView() {
        let view = NSView(frame: NSMakeRect(0.0, 0.0, 50.0, 50.0))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.blue().cgColor
        view.layer?.borderColor = NSColor.blue().cgColor
        view.layer?.borderWidth = 2.0
        self.view = view
    }

    func buildUI() {
        label.drawsBackground = false
        label.isBezeled = false
        label.isBordered = false
        label.isEditable = false
        label.isSelectable = false
        label.stringValue = Defaults[.GitlabToken]!
        view.addSubview(label)
    }

    func makeConstraints() {
        label.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(50.0)
            make.width.equalTo(200.0)
            make.centerX.centerY.equalTo(self.view) // center is missing in swift 3 branch?
        }
    }

    func myAction(sender: AnyObject) {
        app.showTokenViewController()
    }

}
