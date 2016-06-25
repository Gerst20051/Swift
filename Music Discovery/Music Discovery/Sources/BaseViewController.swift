import UIKit

class BaseViewController: UIViewController {

    var app: AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
    }

}
