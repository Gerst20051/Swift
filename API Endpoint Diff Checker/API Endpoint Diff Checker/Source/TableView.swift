import Cocoa

class DiffData {

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

class SavedDiffData {

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
        Entry(fname: "mountain.jpeg", heading: "Heading 2")
    ]

}

class DiffDataSource : NSObject, NSTableViewDataSource, NSTableViewDelegate {

    var data: DiffData {
        return DiffData()
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

class SavedDiffDataSource : NSObject, NSTableViewDataSource, NSTableViewDelegate {

    var data: SavedDiffData {
        return SavedDiffData()
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
        cellView.layer?.backgroundColor = NSColor.greenColor().CGColor
        return cellView
    }
}
