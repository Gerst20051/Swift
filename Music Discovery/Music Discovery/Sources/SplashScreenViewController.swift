import UIKit

class SplashScreenViewController: UIViewController {

    @IBOutlet var equalizerCountainerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        addEqualizerView()
    }

    func addEqualizerView() {
        let equalizerView = AnimatedEqualizerView(containerView: equalizerCountainerView)
        equalizerCountainerView.backgroundColor = UIColor.clearColor()
        equalizerCountainerView.addSubview(equalizerView)
        equalizerView.animate()
    }

}
