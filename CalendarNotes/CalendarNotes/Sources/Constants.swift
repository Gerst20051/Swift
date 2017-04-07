import Material

struct AppColor {
    static let base = Color.blue.darken1
}

enum PromiseError: Error {
    case apiFailure(Error?)
    case invalidResults()
}
