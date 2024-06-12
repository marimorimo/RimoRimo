//
//  TabButtonUIFactory.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/3/24.
//

import UIKit

class TabButtonUIFactory: UIViewController {
    static func tapButton(buttonTitle: String, textColor: UIColor, cornerRadius: Int, backgroundColor: UIColor) -> UIButton {
        let button = UIButton()
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.font = UIFont.pretendard(style: .semiBold, size: 16, isScaled: true)
        button.setTitleColor(textColor, for: .normal)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = CGFloat(cornerRadius)
        button.clipsToBounds = true
        return button
    }
    
    // 라인 버튼
    static func doubleCheckButton(buttonTitle: String, textColor: UIColor, cornerRadius: Int, backgroundColor: UIColor) -> UIButton {
        let button = UIButton()
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.font = UIFont.pretendard(style: .semiBold, size: 16, isScaled: true)
        button.setTitleColor(textColor, for: .normal)
        button.backgroundColor = backgroundColor
        button.layer.borderColor = MySpecialColors.MainColor.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = CGFloat(cornerRadius)
        button.clipsToBounds = true
        return button
    }
}
