import UIKit

open class LeftMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView?

    override open func viewDidLoad() {
        super.viewDidLoad()
        createTableView()
    }

    open func createTableView() {
        tableView = UITableView(frame: CGRect(x: 0, y: (view.frame.size.height - 54.0 * 5.0) / 2.0, width: view.frame.size.width, height: 54.0 * 5.0), style: .plain)
        tableView!.autoresizingMask = [ .flexibleTopMargin, .flexibleBottomMargin, .flexibleWidth ]
        tableView!.backgroundColor = UIColor.clear
        tableView!.backgroundView = nil
        tableView!.bounces = false
        tableView!.dataSource = self
        tableView!.delegate = self
        tableView!.isOpaque = false
        tableView!.separatorStyle = .none
        view.addSubview(tableView!)
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
            case 0:
                sideMenuViewController!.setContentViewController(ViewController(), animated: true)
                sideMenuViewController!.hideMenuViewController()
            case 1:
                sideMenuViewController!.setContentViewController(ViewController(), animated: true)
                sideMenuViewController!.hideMenuViewController()
            default:
                break
        }
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54.0
    }

    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection sectionIndex: Int) -> Int {
        return 5
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            cell!.backgroundColor = .clear
            cell!.selectedBackgroundView = UIView()
            cell!.textLabel?.font = UIFont(name: "HelveticaNeue", size: 21.0)
            cell!.textLabel?.highlightedTextColor = .lightGray
            cell!.textLabel?.textColor = .white
        }
        var titles = [ "Home", "Calendar", "Profile", "Settings", "Log Out" ]
        var images = [ "IconHome", "IconCalendar", "IconProfile", "IconSettings", "IconEmpty" ]
        cell!.textLabel?.text = titles[(indexPath as NSIndexPath).row]
        cell!.imageView?.image = UIImage(named: images[(indexPath as NSIndexPath).row])
        return cell!
    }

}
