import UIKit

class BaseViewController: UIViewController {

    var app: AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }

}
