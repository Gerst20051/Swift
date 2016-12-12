import Material

struct AppColor {
    static let base = Color.indigo.lighten2
    static let sectionHeader = Color.indigo.darken2
    static let tag = Color.indigo.lighten3
}

struct AppConstants {
    static let SectionHeaderFontSize: CGFloat = 26.0
    static let SideMenuFontSize: CGFloat = 21.0
    static let SideMenuRowHeight: CGFloat = 60.0
    static let ToolbarFontSize: CGFloat = 32.0
    static let ToolbarHeight: CGFloat = 60.0
}

struct AppFont {
    static let base = "HelveticaNeue-Thin"
    static let sectionHeader = "HelveticaNeue-UltraLight"
}

struct AppIcon {
    static let add = "add"
    static let back = "back"
    static let menu = "menu"
}

struct AppImage {
    static let background = "background"
}

struct AppString {
    static let AddIdea = "Add Idea"
    static let CurrentIdeas = "Current Ideas"
    static let EnterIdeaIndicators = "Enter Idea Indicators"
    static let HoldingDurationTags = "Holding Duration Tags"
    static let IdeaIndicatorTags = "Idea Indicator Tags"
    static let IdeaInsights = "Idea Insights"
    static let IdeaSourceTags = "Idea Source Tags"
    static let PastIdeas = "Past Ideas"
    static let SentimentTags = "Sentiment Tags"
    static let Settings = "Settings"
}
