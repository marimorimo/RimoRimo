//
//  TextFieldUIFactory.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/3/24.
//

import UIKit

class BorderedStackView: UIStackView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.addBorder([.bottom], color: MySpecialColors.Gray3, width: 1.0)
    }
}

class TextFieldUIFactory {
    static func stackBox() -> UIView {
        return BorderedStackView()
    }
    
    static func textFieldStackView(spacing: Int) -> UIStackView {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = CGFloat(spacing)
        return stackView
    }
    
    static func textField(placeholder: String) -> UITextField {
        let field = UITextField()
        field.font = UIFont.pretendard(style: .regular, size: 14, isScaled: true)
        field.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : MySpecialColors.Gray3])
        field.textColor = MySpecialColors.Gray4
        field.tintColor = MySpecialColors.MainColor
        field.autocorrectionType = .no
        field.spellCheckingType = .no
        return field
    }
    
    static func fieldIcon(name: String) -> UIImageView {
        let icon = UIImageView()
        icon.image = UIImage(named: name)
        return icon
    }
    
    static func deleteIcon(name: String) -> UIImageView {
        let icon = UIImageView()
        icon.image = UIImage(named: name)
        return icon
    }
    
    static func hiddenIcon(name: String) -> UIImageView {
        let icon = UIImageView()
        icon.image = UIImage(named: name)
        return icon
    }
}

extension CALayer {
    func addBorder(_ edges: [UIRectEdge], color: UIColor, width: CGFloat) {
        for edge in edges {
            let border = CALayer()
            switch edge {
            case .top:
                border.frame = CGRect(x: 0, y: 0, width: frame.width, height: width)
            case .bottom:
                border.frame = CGRect(x: 0, y: frame.height - width, width: frame.width, height: width)
            case .left:
                border.frame = CGRect(x: 0, y: 0, width: width, height: frame.height)
            case .right:
                border.frame = CGRect(x: frame.width - width, y: 0, width: width, height: frame.height)
            default:
                break
            }
            
            border.backgroundColor = color.cgColor
            self.addSublayer(border)
        }
    }
}
