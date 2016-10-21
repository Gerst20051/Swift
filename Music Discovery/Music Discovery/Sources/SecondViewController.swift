import SnapKit
import UIKit

class SecondViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        view.backgroundColor = UIColor.blue
        showNavigationButton()
    }

    func showNavigationButton() {
        let button = UIButton()
        button.backgroundColor = UIColor.black
        button.setTitle("Back", for: UIControlState())
        button.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        view.addSubview(button)
        button.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(50.0)
            make.width.equalTo(100.0)
            make.center.equalTo(self.view)
        }
    }

    func buttonClicked() {
        print("Back Button Clicked")
        app.nav.popViewController(animated: true)
    }

}
