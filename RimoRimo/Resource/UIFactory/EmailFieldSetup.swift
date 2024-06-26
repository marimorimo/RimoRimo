//
//  EmailFieldSetup.swift
//  RimoRimo-Refactoring
//
//  Created by wxxd-fxrest on 6/24/24.
//

import UIKit
import SnapKit

class FieldSetup: UIView, UITextFieldDelegate {
    
    var onDeleteIconTapped: (() -> Void)?
    
    private let fieldStackView = TextFieldUIFactory.stackBox()
    private let textFieldStackView = TextFieldUIFactory.textFieldStackView(spacing: 10)
    private let fieldIcon = TextFieldUIFactory.fieldIcon(name: "icon-default")
    let textField = TextFieldUIFactory.textField(placeholder: "필드를 입력해 주세요.")
    private let deleteIcon = TextFieldUIFactory.deleteIcon(name: "close-circle")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()

        textField.delegate = self
        textField.textContentType = .none
        textField.returnKeyType = .next
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(fieldStackView)
        fieldStackView.addSubview(textFieldStackView)
        
        textFieldStackView.addArrangedSubviews(fieldIcon, textField, deleteIcon)
        
        fieldStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        textFieldStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        fieldIcon.snp.makeConstraints {
            $0.width.equalTo(24)
        }
        
        deleteIcon.snp.makeConstraints {
            $0.width.equalTo(24)
        }
        
        deleteIcon.isUserInteractionEnabled = true
        let deleteGesture = UITapGestureRecognizer(target: self, action: #selector(deleteIconTapped))
        deleteIcon.addGestureRecognizer(deleteGesture)
    }
    
    func configureField(placeholder: String, iconName: String, keyboardType: UIKeyboardType) {
        textField.placeholder = placeholder
        fieldIcon.image = UIImage(named: iconName)
        textField.keyboardType = keyboardType
    }
    
    @objc private func deleteIconTapped() {
        textField.text = ""  // Clear the text field
        onDeleteIconTapped?()
    }
}
