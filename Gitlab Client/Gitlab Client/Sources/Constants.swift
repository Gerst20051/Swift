enum PromiseError: ErrorProtocol {
    case ApiFailure(ErrorProtocol?)
    case InvalidProjects()
    case InvalidUrl()
}
