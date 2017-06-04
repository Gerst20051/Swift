import SwiftyUserDefaults

extension DefaultsKeys {
    static let StockTickerDownloadDate = DefaultsKey<Date?>("stock_ticker_download_date")
}

extension Int {
    var isEmpty: Bool {
        return self == 0
    }
}

extension String {
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
}

extension UITableViewCell {
    func removeMargins() {
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        self.selectionStyle = .none
        self.separatorInset = UIEdgeInsets.zero
    }
}
