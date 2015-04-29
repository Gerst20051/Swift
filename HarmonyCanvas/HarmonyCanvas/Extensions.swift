import UIKit

extension String {

    /* var length: Int {
        return count(self)
    } */

    func length() -> Int {
        return count(self)
    }

    var capitalizeFirst: String {
        var result = self
        result.replaceRange(startIndex ... startIndex, with: String(self[startIndex]).capitalizedString)
        return result
    }

    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
    }

    func substring(location: Int, length: Int) -> String! {
        return (self as NSString).substringWithRange(NSMakeRange(location, length))
    }

    subscript(index: Int) -> String! {
        get {
            return self.substring(index, length: 1)
        }
    }

    func location(other: String) -> Int {
        return (self as NSString).rangeOfString(other).location
    }

    func contains(other: String) -> Bool {
        return (self as NSString).containsString(other)
    }

    func isNumeric() -> Bool {
        return (self as NSString).rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).location == NSNotFound
    }

}

extension UIColor {

    convenience init(rgba: String, alpha: CGFloat = 1.0) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var myAlpha: CGFloat = alpha

        if rgba.hasPrefix("#") {
            let index = advance(rgba.startIndex, 1)
            let hex = rgba.substringFromIndex(index)
            let scanner = NSScanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexLongLong(&hexValue) {
                if hex.length() == 6 {
                    red = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
                    blue = CGFloat(hexValue & 0x0000FF) / 255.0
                } else if hex.length() == 8 {
                    red = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue = CGFloat((hexValue & 0x0000FF00) >> 8) / 255.0
                    myAlpha = CGFloat(hexValue & 0x000000FF) / 255.0
                } else {
                    print("invalid rgb string, length should be 6 or 8")
                }
            } else {
                println("scan hex error")
            }
        } else if rgba == "transparent" {
            // ANDREWGERSTSWIFT1.2
            // self.init(CGColor: UIColor.clearColor().CGColor)
            // return
        } else {
            print("invalid rgb string, missing '#' as prefix for string '\(rgba)'")
        }
        self.init(red: red, green: green, blue: blue, alpha: myAlpha)
    }

    func toImage() -> UIImage {
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        self.setFill()
        UIRectFill(rect)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    public class func naiveRandomValueForColor() -> CGFloat {
        return CGFloat(drand48())
    }

    public class func naiveRandomColor() -> UIColor {
        return UIColor(red: naiveRandomValueForColor(), green: naiveRandomValueForColor(), blue: naiveRandomValueForColor(), alpha: 1.0)
    }

    public class func randomValueForColor() -> CGFloat {
        return CGFloat(CGFloat(arc4random()) % 256 / 255.0)
    }

    public class func randomColor() -> UIColor {
        return UIColor(red: randomValueForColor(), green: randomValueForColor(), blue: randomValueForColor(), alpha: 1.0)
    }

    public class func randomToneByColor(color: UIColor) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: randomValueForColor(), brightness: randomValueForColor(), alpha: alpha)
    }

    public class func randomGoldenRatioColor(saturation: CGFloat = 0.5, brightness: CGFloat = 0.95) -> UIColor {
        let goldenRatioConjugate: CGFloat = 0.618033988749895
        var hue = randomValueForColor()
        hue += goldenRatioConjugate
        hue %= 1
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }

}
