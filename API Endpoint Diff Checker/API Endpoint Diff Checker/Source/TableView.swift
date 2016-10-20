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

    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.places.count
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50.0
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = NSView()
        cellView.wantsLayer = true
        cellView.layer?.backgroundColor = NSColor.orange.cgColor
        return cellView
    }

}

class SavedDiffDataSource : NSObject, NSTableViewDataSource, NSTableViewDelegate {

    var data: SavedDiffData {
        return SavedDiffData()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.places.count
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50.0
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = NSView()
        cellView.wantsLayer = true
        cellView.layer?.backgroundColor = NSColor.green.cgColor
        return cellView
    }

}
