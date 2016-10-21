import Cocoa
import SnapKit
import SwiftyUserDefaults

class MainViewController : BaseViewController {

    let scrollView = NSScrollView()
    let tableView = NSTableView()
    let dataSource = TableViewDataSource()

    override func loadView() {
        createView()
        buildUI()
        sendRequest()
    }

    func createView() {
        self.view = NSView()
    }

    func buildUI() {
        if 0 < self.dataSource.data.count {
            buildListViewUI()
            makeListViewConstraints()
        }
    }

    func buildListViewUI() {
        scrollView.autoresizingMask = .viewHeightSizable
        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true
        view.addSubview(scrollView)

        tableView.addTableColumn(NSTableColumn())
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.gridColor = NSColor.clear
        tableView.gridStyleMask = []
        tableView.intercellSpacing = NSSize(width: 1.0, height: 1.0)
        tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.none
        tableView.headerView = nil
    }

    func makeListViewConstraints() {
        scrollView.snp.makeConstraints { (make) -> Void in
            make.left.top.equalTo(0.0)
            make.height.width.equalTo(self.view)
        }
        tableView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(0.0)
            make.width.equalTo(scrollView)
        }
    }

    func sendRequest() {
        _ = Cloud.getProjectList().then { projects -> Void in
            self.dataSource.data = projects
            self.buildUI()
            print("projects => \(projects)")
        }.catch { error in
            print("error => \(error)")
        }
    }

}
