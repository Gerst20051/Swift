import NMPopUpViewSwift
import NVActivityIndicatorView
import SnapKit
import UIKit

class BaseViewController: UIViewController {

    var app: AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    var popUpViewController: PopUpViewControllerSwift?
    var loader: NVActivityIndicatorView!
    var loadingOverlay: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        addLoadingOverlayView()
        addActivityIndicatorView()
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    func addLoadingOverlayView() {
        loadingOverlay = UIView()
        loadingOverlay.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        view.addSubview(loadingOverlay)
        loadingOverlay.hidden = true
        loadingOverlay.snp_makeConstraints { (make) -> Void in
            make.height.width.equalTo(self.view)
            make.center.equalTo(self.view)
        }
    }

    func addActivityIndicatorView() {
        loader = NVActivityIndicatorView(frame: CGRectMake(0.0, 0.0, 120.0, 120.0), type: .Orbit) // SquareSpin
        loader.hidesWhenStopped = true
        view.addSubview(loader)
        loader.snp_makeConstraints { (make) -> Void in
            make.height.width.equalTo(120.0)
            make.center.equalTo(self.view)
        }
    }

    func getPopUpViewNibFile() -> String {
        var nibName = "PopUpViewController"
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
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

    func showLoader() {
        view.bringSubviewToFront(loadingOverlay)
        view.bringSubviewToFront(loader)
        loadingOverlay.hidden = false
        loader.startAnimation()
    }

    func hideLoader() {
        loader.stopAnimation()
        loadingOverlay.hidden = true
    }

}
