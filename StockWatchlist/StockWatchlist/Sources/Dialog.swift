import ZAlertView

class Dialog: ZAlertView {

    init(type: AlertType) {
        super.init(title: nil, message: nil, alertType: type)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

}
