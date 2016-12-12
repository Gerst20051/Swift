import RealmSwift

class Idea: Object {

    dynamic var ticker = ""
    dynamic var name = ""
    dynamic var averageBuyPrice = ""
    dynamic var averageSellPrice = ""
    dynamic var ideaSource: IdeaSource?
    internal var ideaIndicators = List<IdeaIndicator>()
    dynamic var dateCreated = NSDate()
    dynamic var dateClosed: NSDate?
    dynamic var profitable = false
    dynamic var sentiment: IdeaSentiment?
    dynamic var traded = false
    dynamic var holdingDuration: IdeaHoldingDuration?

}

class IdeaIndicator: Object {

    dynamic var label = ""
    dynamic var predefined = false

}

class IdeaSource: Object {

    dynamic var name = ""
    dynamic var predefined = false

}

class IdeaSentiment: Object {

    dynamic var label = ""

}

class IdeaHoldingDuration: Object {

    dynamic var label = ""

}
