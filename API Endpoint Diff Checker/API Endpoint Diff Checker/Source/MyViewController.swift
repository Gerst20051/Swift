import Cocoa
import RealmSwift
import SnapKit

class MyViewController : BaseViewController {

    let listView = NSView()
    let tableView = NSTableView()
    let diffView = NSView()

    override func loadView() {
        let view = NSView()
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
    }

    func buildUI() {
        buildListViewUI()
        buildDiffUI()
    }

    func buildListViewUI() {
        listView.wantsLayer = true
        listView.layer?.backgroundColor = NSColor.whiteColor().CGColor
        self.view.addSubview(listView)

        listView.snp_makeConstraints { (make) -> Void in
            make.left.bottom.equalTo(0.0)
            make.height.equalTo(self.view)
            make.width.equalTo(self.view).multipliedBy(0.25)
        }

        tableView.intercellSpacing = NSSize(width: 1.0, height: 1.0)
        tableView.gridColor = NSColor.clearColor()
        tableView.gridStyleMask = NSTableViewGridLineStyle.GridNone
        tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.None
        tableView.setDelegate(self)
        tableView.setDataSource(self)
        listView.addSubview(tableView)

        tableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(0.0)
            make.width.equalTo(listView)
        }

        let column = NSTableColumn(identifier: "column")
        tableView.addTableColumn(column)
    }

    func buildDiffUI() {
        self.view.addSubview(diffView)

        diffView.snp_makeConstraints { (make) -> Void in
            make.right.bottom.equalTo(0.0)
            make.height.equalTo(self.view)
            make.width.equalTo(self.view).multipliedBy(0.75)
        }

        let topView = NSView()
        topView.wantsLayer = true
        topView.layer?.backgroundColor = NSColor.blueColor().CGColor

        let bottomLeftView = NSView()
        bottomLeftView.wantsLayer = true
        bottomLeftView.layer?.backgroundColor = NSColor.yellowColor().CGColor

        let bottomRightView = NSView()
        bottomRightView.wantsLayer = true
        bottomRightView.layer?.backgroundColor = NSColor.grayColor().CGColor

        diffView.addSubview(topView)
        diffView.addSubview(bottomLeftView)
        diffView.addSubview(bottomRightView)

        topView.snp_makeConstraints { (make) -> Void in
            make.top.left.right.equalTo(0.0)
            make.height.equalTo(diffView).multipliedBy(0.1)
        }
        bottomLeftView.snp_makeConstraints { (make) -> Void in
            make.left.bottom.equalTo(0.0)
            make.height.equalTo(diffView).multipliedBy(0.9)
            make.width.equalTo(diffView).multipliedBy(0.25)
        }
        bottomRightView.snp_makeConstraints { (make) -> Void in
            make.right.bottom.equalTo(0.0)
            make.height.equalTo(diffView).multipliedBy(0.9)
            make.width.equalTo(diffView).multipliedBy(0.75)
        }

        let button = NSButton()
        button.action = "myAction:"
        button.target = self
        bottomRightView.addSubview(button)

        button.snp_makeConstraints { (make) -> Void in
            make.height.width.equalTo(50.0)
            make.center.equalTo(bottomRightView)
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