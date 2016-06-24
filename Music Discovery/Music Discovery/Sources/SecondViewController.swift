import SnapKit
import UIKit

class SecondViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        view.backgroundColor = UIColor.blueColor()
        showNavigationButton()
    }

    func showNavigationButton() {
        let button: UIButton = UIButton()
        button.backgroundColor = UIColor.blackColor()
        button.setTitle("Back", forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(self.buttonClicked), forControlEvents: .TouchUpInside)
        view.addSubview(button)
        button.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(50.0)
            make.width.equalTo(100.0)
            make.center.equalTo(self.view)
        }
    }

    func buttonClicked() {
        print("Back Button Clicked")
        app.nav.popViewControllerAnimated(true)
    }
}
