import UIKit

struct Utils {

    static func openUrl(_ url: String) {
        openUrl(URL(string: url)!)
    }

    static func openUrl(_ url: URL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

}
