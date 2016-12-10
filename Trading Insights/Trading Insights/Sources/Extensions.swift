import SwiftyUserDefaults

extension DefaultsKeys {

}

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
        layoutMargins = UIEdgeInsets.zero
        preservesSuperviewLayoutMargins = false
        selectionStyle = .none
        separatorInset = UIEdgeInsets.zero
    }
}
