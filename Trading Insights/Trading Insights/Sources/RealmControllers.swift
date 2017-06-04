import RealmSwift

class IdeaRealmController {

    let realm: Realm!

    init(realm: Realm) {
        self.realm = realm
    }

    convenience init() {
        self.init(realm: try! Realm())
    }

}

class IdeaIndicatorRealmController {

    let realm: Realm!

    static let defaultIndicators = [
        "3-Day Declining Volume",
        "3-Day Rising Volume",
        "52 Week High",
        "52 Week Low",
        "Bearish Candlestick Pattern",
        "Billionaire Investor Play",
        "Breakout",
        "Bullish Candlestick Pattern",
        "Consolidation Pattern (Watching For Breakout)",
        "Crossover (SMA, RSI, STO, MACD)",
        "Dividend Date",
        "Down At Least 2%",
        "Down At Least 4%",
        "Earnings Reports",
        "Fed Meetings",
        "Fibonacci Lines",
        "Flag Pattern",
        "Gapped Down",
        "Gapped Down (At Least 1%)",
        "Gapped Down (At Least 2%)",
        "Gapped Down on High Volume",
        "Gapped Up",
        "Gapped Up (At Least 1%)",
        "Gapped Up (At Least 2%)",
        "Gapped Up on High Volume",
        "Going Down Fast",
        "Going Up Fast",
        "Head and Shoulders Pattern",
        "High Volume",
        "High Volume (vs 3 Month Average)",
        "High Volume Gainer",
        "High Volume Loser",
        "Higher High (3 Days)",
        "HOD",
        "Interest Rates",
        "Low Volume (vs 3 Month Average)",
        "Low Volume Gainer",
        "Low Volume Loser",
        "Lower Low (3 Days)",
        "Momentum",
        "Narrow Trading Range (Watching For Breakout)",
        "NR4",
        "NR4 Inside Day",
        "NR7",
        "NR7 Inside Day",
        "Options Activity",
        "Overbought",
        "Overbought And Turning",
        "Oversold",
        "Oversold And Turning",
        "Price Crossed Above SMA (9, 20, 50, or 200)",
        "Price Crossed Below SMA (9, 20, 50, or 200)",
        "Resistance Break",
        "RSI Divergence",
        "Sector Movement",
        "Spiking",
        "Support Break",
        "Technical Analysis",
        "Trading Below Strong Resistance (Watching level for further direction)",
        "Trendline Break",
        "Up At Least 2%",
        "Up At Least 4%",
        "Warren Buffett Play",
        "Weakening Downtrend (Pattern)",
        "Weakening Downtrend (Volume)",
        "Weakening Uptrend (Pattern)",
        "Weakening Uptrend (Volume)"
    ]

    init(realm: Realm) {
        self.realm = realm
    }

    convenience init() {
        self.init(realm: try! Realm())
    }

    func isPopulated() -> Bool {
        return !realm.objects(IdeaIndicator.self).isEmpty
    }

    func populate() {

    }

}

class IdeaSourceRealmController {

    let realm: Realm!

    static let defaultSources = [
        "Action Forex Signals",
        "Benzinga",
        "Blogs",
        "Blue Horseshoe Stocks",
        "Broad Street",
        "BuyingBreakOuts",
        "CNBC",
        "DayTrading.Buzz",
        "IncredibleTrade",
        "InvestorsHub",
        "James Taulman",
        "Jim Cramer",
        "MaxPipFX",
        "MC Top Stocks",
        "MicroCapDaily",
        "missingSTEP",
        "Momentum Stock Alert",
        "News",
        "PennyStockOracle",
        "Peter Schiff",
        "Podcast",
        "PromotionStockSecrets",
        "Stock Market Leader",
        "StockTwits",
        "Street Picks",
        "TheStreetSweeper",
        "Tim Sykes",
        "Twitter",
        "UltimateStockAlerts"
    ]

    init(realm: Realm) {
        self.realm = realm
    }

    convenience init() {
        self.init(realm: try! Realm())
    }

    func isPopulated() -> Bool {
        return !realm.objects(IdeaSource.self).isEmpty
    }

    func populate() {

    }

}

class IdeaSentimentRealmController {

    let realm: Realm!

    static let defaultSentiments = [
        "Bearish (Short)",
        "Bullish (Long)",
        "Holding",
        "Watching For Direction"
    ]

    init(realm: Realm) {
        self.realm = realm
    }

    convenience init() {
        self.init(realm: try! Realm())
    }

    func isPopulated() -> Bool {
        return !realm.objects(IdeaSource.self).isEmpty
    }

    func populate() {

    }

}

class IdeaHoldingDurationRealmController {

    let realm: Realm!

    static let defaultHoldingDurations = [
        "After-Hours",
        "Intraday",
        "Long-Term",
        "Overnight",
        "Pre-Market",
        "Short-Term",
        "Unknown",
        "Watchlist"
    ]

    init(realm: Realm) {
        self.realm = realm
    }

    convenience init() {
        self.init(realm: try! Realm())
    }

    func isPopulated() -> Bool {
        return !realm.objects(IdeaSource.self).isEmpty
    }

    func populate() {

    }

}
