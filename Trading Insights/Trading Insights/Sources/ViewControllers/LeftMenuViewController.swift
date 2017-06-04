import UIKit

open class LeftMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView?
    let titles = [
        AppString.AddIdea,
        AppString.CurrentIdeas,
        AppString.PastIdeas,
        AppString.IdeaInsights,
        AppString.Settings
    ]

    override open func viewDidLoad() {
        super.viewDidLoad()
        createTableView()
    }

    open func createTableView() {
        tableView = UITableView(frame: CGRect(x: 0.0, y: (view.frame.size.height - AppConstants.SideMenuRowHeight * CGFloat(titles.count)) / 2.0, width: view.frame.size.width, height: AppConstants.SideMenuRowHeight * CGFloat(titles.count)), style: .plain)
        tableView!.autoresizingMask = [ .flexibleTopMargin, .flexibleBottomMargin, .flexibleWidth ]
        tableView!.backgroundColor = .clear
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
                sideMenuViewController!.setContentViewController(AddIdeaViewController(), animated: true)
            case 1:
                sideMenuViewController!.setContentViewController(CurrentIdeasViewController(), animated: true)
            case 2:
                sideMenuViewController!.setContentViewController(PastIdeasViewController(), animated: true)
            case 3:
                sideMenuViewController!.setContentViewController(IdeaInsightsViewController(), animated: true)
            case 4:
                sideMenuViewController!.setContentViewController(SettingsViewController(), animated: true)
            default:
                break
        }
        sideMenuViewController!.hideMenuViewController()
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AppConstants.SideMenuRowHeight
    }

    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection sectionIndex: Int) -> Int {
        return titles.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getTableViewCell(tableView)
        cell.textLabel?.text = titles[(indexPath as NSIndexPath).row]
        return cell
    }

    func getTableViewCell(_ tableView: UITableView) -> UITableViewCell {
        let cellIdentifier = "Cell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            cell.backgroundColor = .clear
            cell.selectedBackgroundView = UIView()
            cell.textLabel?.font = UIFont(name: AppFont.base, size: AppConstants.SideMenuFontSize)
            cell.textLabel?.highlightedTextColor = .white
            cell.textLabel?.textColor = .white
            return cell
        }
        return cell
    }

}
