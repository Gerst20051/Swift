import NMPopUpViewSwift
import UIKit

class BaseViewController: UIViewController {

    var app: AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    var popUpViewController: PopUpViewControllerSwift?

    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
    }

    func getPopUpViewNibFile() -> String {
        var nibName = "PopUpViewController"
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            nibName = "PopUpViewController_iPad"
        } else {
            if UIScreen.mainScreen().bounds.size.width > 320.0 {
                if UIScreen.mainScreen().scale == 3.0 {
                    nibName = "PopUpViewController_iPhone6Plus"
                } else {
                    nibName = "PopUpViewController_iPhone6"
                }
            }
        }
        return nibName
    }

    func showPopupView(image image: String, title: String, message: String) {
        popUpViewController = PopUpViewControllerSwift(nibName: getPopUpViewNibFile(), bundle: NSBundle(forClass: PopUpViewControllerSwift.self))
        popUpViewController!.title = title
        popUpViewController!.showInView(view, withImage: UIImage(named: image), withMessage: message, animated: true)
    }

}
