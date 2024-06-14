
import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >>  8) & 0xFF) / 255.0
        let b = Double((rgb >>  0) & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

enum MySpecialColors {
    //hex code
    static let MainColor        = Color(hex: "#12A76E")
    static let Green4           = Color(hex: "#12A76E")
    static let Green3           = Color(hex: "#00D583")
    static let Green2           = Color(hex: "#9CF0B9")
    static let Green1           = Color(hex: "#DFF4F1")
    static let RedOrange        = Color(hex: "#FC926A")
    static let Gray1            = Color(hex: "#F0F0F0")
    static let Gray2            = Color(hex: "#D9D9D9")
    static let Gray3            = Color(hex: "#9E9E9E")
    static let Gray4            = Color(hex: "#555555")
    static let Black            = Color(hex: "#2D2D2D")
    static let Red              = Color(hex: "#EE2000")

    static let WidgetUnderLine  = Color(hex: "#DCDCDC")

    //color        asset
    static let customColor  = Color("")
}
