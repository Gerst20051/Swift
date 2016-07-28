import Cocoa
import SnapKit

class TokenViewController : BaseViewController {

    let button = NSButton()
    let input = NSTextField(frame: NSMakeRect(20.0, 20.0, 200.0, 40.0))

    override func loadView() {
        createView()
        buildUI()
        makeConstraints()
    }

    func createView() {
        let view = NSView(frame: NSMakeRect(0.0, 0.0, 50.0, 50.0))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.green().cgColor
        view.layer?.borderColor = NSColor.green().cgColor
        view.layer?.borderWidth = 2.0
        self.view = view
    }

    func buildUI() {
        self.view.addSubview(input)
        button.action = #selector(TokenViewController.myAction)
        button.target = self
        button.title = "Continue"
        self.view.addSubview(button)
    }

    func makeConstraints() {
        input.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view).offset(-40.0)
            make.height.equalTo(20.0)
            make.width.equalTo(200.0)
        }
        button.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view).offset(20.0)
            make.height.equalTo(40.0)
            make.width.equalTo(120.0)
        }
    }

    func myAction(sender: AnyObject) {
        app.showMainViewController()
    }

}
