import SwiftyUserDefaults
import UIKit

extension DefaultsKeys {
    static let HelpOverlayShownForPinchGesture = DefaultsKey<Bool>("help_overlay_shown_for_pinch_gesture")
    static let HelpOverlayShownForSpreadGesture = DefaultsKey<Bool>("help_overlay_shown_for_spread_gesture")
    static let PlaylistVersion = DefaultsKey<Int>("playlist_version")
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
        self.layoutMargins = UIEdgeInsetsZero
        self.preservesSuperviewLayoutMargins = false
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.separatorInset = UIEdgeInsetsZero
    }
}
