import Cocoa
import SnapKit

class TableViewDataSource : NSObject, NSTableViewDataSource, NSTableViewDelegate {

    var data = [GitlabProjectResult]()

    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 20.0
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // var cellView = tableView.make(withIdentifier: "cellView", owner: self)
        // if cellView == nil {
        //     cellView = NSView()
        //     cellView?.identifier = "cellView"
        // }
        // cellView?.wantsLayer = true
        // cellView?.layer?.backgroundColor = NSColor.orange().cgColor

        var textView = tableView.make(withIdentifier: "textView", owner: self) as? NSTextView
        if textView == nil {
            textView = NSTextView()
            textView?.identifier = "textView"
        }
        textView?.string = String(data[row].name!)

        // cellView?.addSubview(textView!)

        // textView?.snp.makeConstraints { (make) -> Void in
        //     make.left.top.equalTo(cellView!)
        //     make.height.width.equalTo(cellView!)
        // }

        // return cellView

        return textView
    }

}
