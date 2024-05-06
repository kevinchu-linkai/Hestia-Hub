import SwiftUI
import UIKit

extension UIColor {
    @nonobjc class var amethyst: UIColor {
        return UIColor(red: 57.0 / 255.0, green: 104.0 / 255.0, blue: 254.0 / 255.0, alpha: 1.0)
    }

    @nonobjc class var black: UIColor {
        return UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
    }

    @nonobjc class var cloud: UIColor {
        return UIColor(red: 179.0 / 255.0, green: 179.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0)
    }

    @nonobjc class var daisy: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }

    @nonobjc class var daisy2: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 253.0 / 255.0, blue: 253.0 / 255.0, alpha: 1.0)
    }

    @nonobjc class var slate: UIColor {
        return UIColor(red: 139.0 / 255.0, green: 139.0 / 255.0, blue: 139.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var salmon: UIColor {
        return UIColor(red: 84.0 / 255.0, green: 172.0 / 255.0, blue: 119.0 / 255.0, alpha: 1.0)
    }

}

extension Color {
    init(cBlue: UIColor) {
        self.init(red: 57.0 / 255.0, green: 104.0 / 255.0, blue: 254.0 / 255.0)
    }
    init(cBlack: UIColor) {
        self.init(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0)
    }
    init(cCloud: UIColor) {
        self.init(red: 179.0 / 255.0, green: 179.0 / 255.0, blue: 179.0 / 255.0)
    }
    init(cDaisy1: UIColor) {
        self.init(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0)
    }
    init(cDaisy2: UIColor) {
        self.init(red: 255.0 / 255.0, green: 253.0 / 255.0, blue: 253.0 / 255.0)
    }
    init(cSlate: UIColor) {
        self.init(red: 139.0 / 255.0, green: 139.0 / 255.0, blue: 139.0 / 255.0)
    }
}
