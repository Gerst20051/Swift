import Cocoa
import RealmSwift
import SnapKit

class MyViewController : BaseViewController {

    override func loadView() {
        let view = NSView(frame: NSMakeRect(0, 0, 100.0, 100.0))
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
            make.width.height.equalTo(50.0)
            make.center.equalTo(self.view)
        }
    }

    func myAction(sender: AnyObject) {
        updateDataStore()
        app.showMySecondViewController()
    }

    func updateDataStore() {
        // RealmUtils.logDebugInfo()
        // RealmUtils.deleteAllData()
        let realm = try! Realm()

        let myDiff = Diff()
        myDiff.id = (realm.objects(Diff).filter("deleted == nil").sorted("id", ascending: false).first?.id ?? -1) + 1
        myDiff.name = "Test Diff"

        try! realm.write {
            realm.add(myDiff)
        }
    }

}