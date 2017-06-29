import Material
import UIKit

class GenericTableViewCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        applyGenericStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func applyGenericStyle() {
        backgroundColor = Color.clear
        removeMargins()
    }

}

class CustomTableViewCell: GenericTableViewCell {

    let customView = UIView()
    let simpleLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        applyCustomStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func applyCustomStyle() {
        customView.removeFromSuperview()
        contentView.addSubview(customView)
        customView.snp.makeConstraints { make -> Void in
            make.center.equalTo(contentView)
            make.height.equalTo(contentView)
            make.width.equalTo(contentView)
        }
        buildSimpleCell()
        simpleLabel.textColor = Color.darkText.secondary
    }

    func buildSimpleCell() {
        customView.addSubview(simpleLabel)
        simpleLabel.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(contentView)
            make.top.equalTo(contentView)
            make.left.equalTo(contentView).offset(10.0)
            make.right.equalTo(contentView).offset(-10.0)
        }
    }

}
