import UIKit

extension Int {
    var isEmpty: Bool {
        return self == 0
    }
}

extension String {
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
}

extension UITableViewCell {
    func removeMargins() {
        self.layoutMargins = UIEdgeInsetsZero
        self.preservesSuperviewLayoutMargins = false
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.separatorInset = UIEdgeInsetsZero
    }
}
