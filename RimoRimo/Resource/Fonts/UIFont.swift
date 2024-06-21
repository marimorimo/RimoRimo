//
//  UIFont.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/3/24.
//


import Foundation
import UIKit

extension UIFont {
    
    enum PretendardStyle: String {
        case black = "Pretendard-Black"
        case bold = "Pretendard-Bold"
        case extraBold = "Pretendard-ExtraBold"
        case extraLight = "Pretendard-ExtraLight"
        case light = "Pretendard-Light"
        case medium = "Pretendard-Medium"
        case regular = "Pretendard-Regular"
        case semiBold = "Pretendard-SemiBold"
        case thin = "Pretendard-Thin"
    }
    
    static func pretendard(style: PretendardStyle, size: CGFloat, isScaled: Bool = true) -> UIFont {
        guard let font = UIFont(name: style.rawValue, size: size) else {
            debugPrint("Pretendard font \(style.rawValue) can't be loaded")
            return UIFont.systemFont(ofSize: size)
        }
        
        return isScaled ? UIFontMetrics.default.scaledFont(for: font) : font
    }
}
