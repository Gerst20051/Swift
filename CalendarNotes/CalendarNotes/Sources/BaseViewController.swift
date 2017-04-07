import UIKit

class BaseViewController: UIViewController {

    var app: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

}
