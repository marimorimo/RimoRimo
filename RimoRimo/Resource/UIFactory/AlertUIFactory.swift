//
//  AlertUIFactory.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/3/24.
//

import UIKit

class AlertUIFactory: UIViewController {
    static func alertBackView() -> UIView {
        let view = UIView()
        view.backgroundColor = MySpecialColors.Gray3.withAlphaComponent(0.5)
        return view
    }
    
    static func alertView() -> UIView {
        let view = UIView()
        view.backgroundColor = MySpecialColors.Gray1
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }
    
    static func alertTitle(titleText: String, textColor: UIColor, fontSize: Int) -> UILabel {
        let text = UILabel()
        text.text = titleText
        text.textColor = textColor
        text.font = UIFont.pretendard(style: .semiBold, size: 16, isScaled: true)
        return text
    }
    
    static func alertSubTitle(subTitleText: String, textColor: UIColor, fontSize: Int) -> UILabel {
        let text = UILabel()
        text.text = subTitleText
        text.textColor = textColor
        text.font = UIFont.pretendard(style: .regular, size: 14, isScaled: true)
        return text
    }
    
    static func widthLine() -> UIView {
        let view = UIView()
        view.backgroundColor = MySpecialColors.Gray2
        return view
    }
    
    static func heightLine() -> UIView {
        let view = UIView()
        view.backgroundColor = MySpecialColors.Gray2
        return view
    }
    
    static func cancleView() -> UIView {
        let view = UIView()
        return view
    }
    
    static func cancleLabel(cancleText: String, textColor: UIColor, fontSize: Int) -> UILabel {
        let label = UILabel()
        label.text = cancleText
        label.textColor = textColor
        label.font = UIFont.pretendard(style: .medium, size: 14, isScaled: true)
        return label
    }
    
    static func checkView() -> UIView {
        let view = UIView()
        return view
    }
    
    static func checkLabel(cancleText: String, textColor: UIColor, fontSize: Int) -> UILabel {
        let label = UILabel()
        label.text = cancleText
        label.textColor = textColor
        label.font = UIFont.pretendard(style: .semiBold, size: 14, isScaled: true)
        return label
    }
}
