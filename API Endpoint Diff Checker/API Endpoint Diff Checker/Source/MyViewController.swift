import Cocoa
import RealmSwift
import SnapKit

class MyViewController : BaseViewController {

    let listView = NSView()
    let diffTableView = NSTableView()
    let diffDataSource = DiffDataSource()
    let diffView = NSView()
    let savedDiffTableView = NSTableView()
    let savedDiffDataSource = SavedDiffDataSource()

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
        listView.layer?.backgroundColor = NSColor.white.cgColor
        self.view.addSubview(listView)

        listView.snp.makeConstraints { (make) -> Void in
            make.left.bottom.equalTo(0.0)
            make.height.equalTo(self.view)
            make.width.equalTo(self.view).multipliedBy(0.25)
        }

        diffTableView.intercellSpacing = NSSize(width: 1.0, height: 1.0)
        diffTableView.gridColor = NSColor.clear
        diffTableView.gridStyleMask = NSTableViewGridLineStyle()
        diffTableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.none
        diffTableView.delegate = diffDataSource
        diffTableView.dataSource = diffDataSource
        listView.addSubview(diffTableView)

        diffTableView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(0.0)
            make.width.equalTo(listView)
        }

        let column = NSTableColumn(identifier: "diffcolumn")
        diffTableView.addTableColumn(column)
    }

    func buildDiffUI() {
        self.view.addSubview(diffView)

        diffView.snp.makeConstraints { (make) -> Void in
            make.right.bottom.equalTo(0.0)
            make.height.equalTo(self.view)
            make.width.equalTo(self.view).multipliedBy(0.75)
        }

        let topView = NSView()
        topView.wantsLayer = true
        topView.layer?.backgroundColor = NSColor.blue.cgColor

        let bottomLeftView = NSView()
        bottomLeftView.wantsLayer = true
        bottomLeftView.layer?.backgroundColor = NSColor.yellow.cgColor

        let bottomRightView = NSView()
        bottomRightView.wantsLayer = true
        bottomRightView.layer?.backgroundColor = NSColor.gray.cgColor

        diffView.addSubview(topView)
        diffView.addSubview(bottomLeftView)
        diffView.addSubview(bottomRightView)

        topView.snp.makeConstraints { (make) -> Void in
            make.top.left.right.equalTo(0.0)
            make.height.equalTo(diffView).multipliedBy(0.1)
        }
        bottomLeftView.snp.makeConstraints { (make) -> Void in
            make.left.bottom.equalTo(0.0)
            make.height.equalTo(diffView).multipliedBy(0.9)
            make.width.equalTo(diffView).multipliedBy(0.25)
        }
        bottomRightView.snp.makeConstraints { (make) -> Void in
            make.right.bottom.equalTo(0.0)
            make.height.equalTo(diffView).multipliedBy(0.9)
            make.width.equalTo(diffView).multipliedBy(0.75)
        }

        let button = NSButton()
        button.action = #selector(MyViewController.myAction(_:))
        button.target = self
        bottomRightView.addSubview(button)

        button.snp.makeConstraints { (make) -> Void in
            make.height.width.equalTo(50.0)
            make.center.equalTo(bottomRightView)
        }

        savedDiffTableView.intercellSpacing = NSSize(width: 1.0, height: 1.0)
        savedDiffTableView.gridColor = NSColor.clear
        savedDiffTableView.gridStyleMask = NSTableViewGridLineStyle()
        savedDiffTableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.none
        savedDiffTableView.delegate = savedDiffDataSource
        savedDiffTableView.dataSource = savedDiffDataSource
        bottomLeftView.addSubview(savedDiffTableView)

        savedDiffTableView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(0.0)
            make.width.equalTo(bottomLeftView)
        }

        let column = NSTableColumn(identifier: "saveddiffcolumn")
        savedDiffTableView.addTableColumn(column)
    }

    func myAction(_ sender: AnyObject) {
        updateDataStore()
        app.showMySecondViewController()
    }

    func updateDataStore() {
        // RealmUtils.logDebugInfo()
        // RealmUtils.deleteAllData()
        let realm = try! Realm()

        let myDiff = Diff()
        myDiff.id = (realm.objects(Diff.self).filter("deleted == nil").sorted(byProperty: "id", ascending: false).first?.id ?? -1) + 1
        myDiff.name = "Test Diff"

        try! realm.write {
            realm.add(myDiff)
        }
    }

}
