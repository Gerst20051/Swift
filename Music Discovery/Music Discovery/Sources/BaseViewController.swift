import NMPopUpViewSwift
import NVActivityIndicatorView
import SnapKit
import UIKit

class BaseViewController: UIViewController {

    var app: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
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

    override var prefersStatusBarHidden : Bool {
        return true
    }

    func addLoadingOverlayView() {
        loadingOverlay = UIView()
        loadingOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.addSubview(loadingOverlay)
        loadingOverlay.isHidden = true
        loadingOverlay.snp.makeConstraints { (make) -> Void in
            make.height.width.equalTo(self.view)
            make.center.equalTo(self.view)
        }
    }

    func addActivityIndicatorView() {
        loader = NVActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 120.0, height: 120.0), type: .orbit) // SquareSpin
        view.addSubview(loader)
        loader.snp.makeConstraints { (make) -> Void in
            make.height.width.equalTo(120.0)
            make.center.equalTo(self.view)
        }
    }

    func getPopUpViewNibFile() -> String {
        var nibName = "PopUpViewController"
        if UIDevice.current.userInterfaceIdiom == .pad {
            nibName = "PopUpViewController_iPad"
        } else {
            if UIScreen.main.bounds.size.width > 320.0 {
                if UIScreen.main.scale == 3.0 {
                    nibName = "PopUpViewController_iPhone6Plus"
                } else {
                    nibName = "PopUpViewController_iPhone6"
                }
            }
        }
        return nibName
    }

    func showPopupView(image: String, title: String, message: String) {
        popUpViewController = PopUpViewControllerSwift(nibName: getPopUpViewNibFile(), bundle: Bundle(for: PopUpViewControllerSwift.self))
        popUpViewController!.title = title
        popUpViewController!.showInView(view, withImage: UIImage(named: image), withMessage: message, animated: true)
    }

    func showLoader() {
        view.bringSubview(toFront: loadingOverlay)
        view.bringSubview(toFront: loader)
        loadingOverlay.isHidden = false
        loader.startAnimating()
    }

    func hideLoader() {
        loader.stopAnimating()
        loadingOverlay.isHidden = true
    }

}
