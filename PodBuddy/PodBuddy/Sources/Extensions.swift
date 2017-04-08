import SwiftyUserDefaults

extension DefaultsKeys {}

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

extension Array {
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
}

extension UITableViewCell {
    func removeMargins() {
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        self.selectionStyle = .none
        self.separatorInset = UIEdgeInsets.zero
    }
}
