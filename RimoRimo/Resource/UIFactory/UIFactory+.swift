//
//  UIFactory+.swift
//  RimoRimo-Refactoring
//
//  Created by wxxd-fxrest on 6/24/24.
//

import UIKit
import Then

class UIFactory_: UIViewController {
    static func makeView(backgroundColor: UIColor, cornerRadius: CGFloat = 0) -> UIView {
        return UIView().then {
            $0.backgroundColor = backgroundColor
            $0.layer.cornerRadius = cornerRadius
            $0.clipsToBounds = true
        }
    }

//    let backgroundView = UIFactory.makeView(backgroundColor: .gray, cornerRadius: 10)
    
    static func makeLabel(text: String, textColor: UIColor, font: UIFont, textAlignment: NSTextAlignment = .left) -> UILabel {
        return UILabel().then {
            $0.text = text
            $0.textColor = textColor
            $0.font = font
            $0.textAlignment = textAlignment
        }
    }
//    let titleLabel = UIFactory.makeLabel(text: "Welcome!", textColor: .black, font: UIFont.systemFont(ofSize: 18, weight: .bold), textAlignment: .center)
    
    static func makeButton(title: String, titleColor: UIColor, font: UIFont, backgroundColor: UIColor, cornerRadius: CGFloat = 0) -> UIButton {
        return UIButton().then {
            $0.setTitle(title, for: .normal)
            $0.setTitleColor(titleColor, for: .normal)
            $0.titleLabel?.font = font
            $0.backgroundColor = backgroundColor
            $0.layer.cornerRadius = cornerRadius
            $0.clipsToBounds = true
        }
    }
    
    static func makeImageButton(image: String, tintColor: UIColor) -> UIButton {
        return UIButton().then {
            $0.setImage(UIImage(systemName: image), for: .normal)
            $0.tintColor = tintColor
        }
    }
//    let actionButton = UIFactory.makeButton(title: "Tap Me", titleColor: .white, font: UIFont.systemFont(ofSize: 16, weight: .semibold), backgroundColor: .blue, cornerRadius: 8)
    
    static func makeStackView(arrangedSubviews: [UIView], axis: NSLayoutConstraint.Axis, spacing: CGFloat) -> UIStackView {
        return UIStackView(arrangedSubviews: arrangedSubviews).then {
            $0.axis = axis
            $0.spacing = spacing
            $0.alignment = .fill
            $0.distribution = .fill
        }
    }
//    let label1 = UIFactory.makeLabel(text: "Label 1", textColor: .black, font: UIFont.systemFont(ofSize: 16))
//    let label2 = UIFactory.makeLabel(text: "Label 2", textColor: .black, font: UIFont.systemFont(ofSize: 16))
//    let label3 = UIFactory.makeLabel(text: "Label 3", textColor: .black, font: UIFont.systemFont(ofSize: 16))
//
//    let stackView = UIFactory.makeStackView(arrangedSubviews: [label1, label2, label3], axis: .vertical, spacing: 10)
//    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    static func makeImageView(image: UIImage?, contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImageView {
        return UIImageView().then {
            $0.image = image
            $0.contentMode = contentMode
            $0.clipsToBounds = true
        }
    }
//    let imageView = UIFactory.makeImageView(image: UIImage(named: "placeholder_image"))
//    imageView.translatesAutoresizingMaskIntoConstraints = false
    
    static func makeTextField(placeholder: String? = nil, textColor: UIColor = .black, font: UIFont = .systemFont(ofSize: 14), backgroundColor: UIColor = .clear, cornerRadius: CGFloat = 0) -> UITextField {
         return UITextField().then {
             $0.placeholder = placeholder
             $0.textColor = textColor
             $0.font = font
             $0.backgroundColor = backgroundColor
             $0.layer.cornerRadius = cornerRadius
             $0.clipsToBounds = true
         }
     }
//    let textField = UIFactory.makeTextField(placeholder: "Enter text", textColor: .black, font: UIFont.systemFont(ofSize: 16), backgroundColor: .white, cornerRadius: 8)
     
     static func makeTableView(style: UITableView.Style = .plain, separatorStyle: UITableViewCell.SeparatorStyle = .singleLine) -> UITableView {
         return UITableView(frame: .zero, style: style).then {
             $0.separatorStyle = separatorStyle
             $0.backgroundColor = .clear
             $0.showsVerticalScrollIndicator = false
             $0.showsHorizontalScrollIndicator = false
         }
     }
//    let tableView = UIFactory.makeTableView(style: .plain, separatorStyle: .singleLine)
//    tableView.translatesAutoresizingMaskIntoConstraints = false
    
     static func makeCollectionView(layout: UICollectionViewLayout) -> UICollectionView {
         return UICollectionView(frame: .zero, collectionViewLayout: layout).then {
             $0.backgroundColor = .clear
             $0.showsVerticalScrollIndicator = false
             $0.showsHorizontalScrollIndicator = false
         }
     }
//    let flowLayout = UICollectionViewFlowLayout()
//    flowLayout.scrollDirection = .vertical
//    let collectionView = UIFactory.makeCollectionView(layout: flowLayout)
//    collectionView.translatesAutoresizingMaskIntoConstraints = false

     static func makeScrollView() -> UIScrollView {
         return UIScrollView().then {
             $0.showsVerticalScrollIndicator = true
             $0.showsHorizontalScrollIndicator = false
         }
     }
//    let scrollView = UIFactory.makeScrollView()
//    scrollView.translatesAutoresizingMaskIntoConstraints = false
     
}
