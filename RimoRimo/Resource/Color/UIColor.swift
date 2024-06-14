//
//  UIColor.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/3/24.
//

import Foundation
import UIKit

extension UIColor {

    convenience init(hex: String) {

        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hex.hasPrefix("#") {
            hex.remove(at: hex.startIndex)
        }

        guard hex.count == 6 else {
            self.init(cgColor: UIColor.gray.cgColor)
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)

        self.init(
            red:   CGFloat((rgbValue & 0xFF0000) >> 16) / 255,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255,
            blue:  CGFloat(rgbValue & 0x0000FF) / 255,
            alpha: 1
        )
    }
}

enum MySpecialColors {
    //hex code
    static let MainColor = UIColor(hex: "#12A76E")
    static let Green4 = UIColor(hex: "#12A76E")
    static let Green3 = UIColor(hex: "#00D583")
    static let Green2 = UIColor(hex: "#9CF0B9")
    static let Green1 = UIColor(hex: "#DFF4F1")
    static let RedOrange = UIColor(hex: "#FC926A")
    static let Gray1 = UIColor(hex: "#F0F0F0")
    static let Gray2 = UIColor(hex: "#D9D9D9")
    static let Gray3 = UIColor(hex: "#9E9E9E")
    static let Gray4 = UIColor(hex: "#555555")
    static let Black = UIColor(hex: "#2D2D2D")
    static let Red = UIColor(hex: "#EE2000")
    // 추가
    static let Blue = UIColor(hex: "#77CFC8")
    static let DayBlue = UIColor(hex: "#C5F4E2")

    //color asset
    static let customColor  = UIColor(named: "")
}
