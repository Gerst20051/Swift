import Forrest

class ForrestUtils {

    class func runTest() {
        let forrest = Forrest()
        let pwd = forrest.run("pwd").stdout // Get Current Directory
        print("pwd => \(pwd)")
        let swiftFiles = forrest.run("ls -la | grep swift").stdout // Piped Commands
        print("swiftFiles => \(swiftFiles)")
    }

}
