enum PromiseError: Error {
    case apiFailure(Error?)
    case invalidProjects()
    case invalidUrl()
}
