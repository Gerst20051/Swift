import UIKit

extension String {

    func length() -> Int {
        return self.characters.count
    }

    var capitalizeFirst: String {
        var result = self
        result.replaceSubrange(startIndex ... startIndex, with: String(self[startIndex]).capitalized)
        return result
    }

    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    func substring(_ location: Int, length: Int) -> String! {
        return (self as NSString).substring(with: NSMakeRange(location, length))
    }

    subscript(index: Int) -> String! {
        get {
            return self.substring(index, length: 1)
        }
    }

    func location(_ other: String) -> Int {
        return (self as NSString).range(of: other).location
    }

    func contains(_ other: String) -> Bool {
        return self.range(of: other) != nil
    }

    func isNumeric() -> Bool {
        return (self as NSString).rangeOfCharacter(from: CharacterSet.decimalDigits.inverted).location == NSNotFound
    }

}

extension UIColor {

    convenience init(rgba: String, alpha: CGFloat = 1.0) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var myAlpha: CGFloat = alpha

        if rgba.hasPrefix("#") {
            let index = rgba.characters.index(rgba.startIndex, offsetBy: 1)
            let hex = rgba.substring(from: index)
            let scanner = Scanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexInt64(&hexValue) {
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
                print("scan hex error")
            }
        } else if rgba == "transparent" {
            self.init(cgColor: UIColor.clear.cgColor)
            return
        } else {
            print("invalid rgb string, missing '#' as prefix for string '\(rgba)'")
        }
        self.init(red: red, green: green, blue: blue, alpha: myAlpha)
    }

    func toImage() -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
        self.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    public class func naiveRandomValueForColor() -> CGFloat {
        return CGFloat(drand48())
    }

    public class func naiveRandomColor() -> UIColor {
        return UIColor(red: naiveRandomValueForColor(), green: naiveRandomValueForColor(), blue: naiveRandomValueForColor(), alpha: 1.0)
    }

    public class func randomValueForColor() -> CGFloat {
        return CGFloat(CGFloat(arc4random()).truncatingRemainder(dividingBy: 256) / 255.0)
    }

    public class func randomColor() -> UIColor {
        return UIColor(red: randomValueForColor(), green: randomValueForColor(), blue: randomValueForColor(), alpha: 1.0)
    }

    public class func randomToneByColor(_ color: UIColor) -> UIColor {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: randomValueForColor(), brightness: randomValueForColor(), alpha: alpha)
    }

    public class func randomGoldenRatioColor(_ saturation: CGFloat = 0.5, brightness: CGFloat = 0.95) -> UIColor {
        let goldenRatioConjugate: CGFloat = 0.618033988749895
        var hue = randomValueForColor()
        hue += goldenRatioConjugate
        hue.formTruncatingRemainder(dividingBy: 1.0)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }

}
