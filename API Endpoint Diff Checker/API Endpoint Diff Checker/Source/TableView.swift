import Cocoa

class Data {

    class Entry {
        let filename: String
        let heading: String
        init(fname: String, heading: String) {
            self.heading = heading
            self.filename = fname
        }
    }

    let places = [
        Entry(fname: "bridge.jpeg", heading: "Heading 1"),
        Entry(fname: "mountain.jpeg", heading: "Heading 2"),
        Entry(fname: "snow.jpeg", heading: "Heading 3"),
        Entry(fname: "sunset.jpeg", heading: "Heading 4")
    ]

}

extension BaseViewController : NSTableViewDataSource, NSTableViewDelegate {

    var data: Data {
        return Data()
    }

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return data.places.count
    }

    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50.0
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = NSView()
        cellView.wantsLayer = true
        cellView.layer?.backgroundColor = NSColor.orangeColor().CGColor
        return cellView
    }
}
