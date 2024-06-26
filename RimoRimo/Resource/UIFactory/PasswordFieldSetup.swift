//
//  PasswordFieldSetup.swift
//  RimoRimo-Refactoring
//
//  Created by wxxd-fxrest on 6/24/24.
//

import UIKit
import SnapKit

class SecureFieldSetup: UIView, UITextFieldDelegate {
    
    var onHiddenIconTapped: (() -> Void)?
    var onDeleteIconTapped: (() -> Void)?
    
    private let fieldStackView = TextFieldUIFactory.stackBox()
    private let textFieldStackView = TextFieldUIFactory.textFieldStackView(spacing: 10)
    private let fieldIcon = TextFieldUIFactory.fieldIcon(name: "lock")
    let textField = TextFieldUIFactory.textField(placeholder: "비밀번호를 입력해 주세요.")
    
    let hiddenIcon = TextFieldUIFactory.hiddenIcon(name: "show-block")
    private let deleteIcon = TextFieldUIFactory.deleteIcon(name: "close-circle")
    private lazy var buttonStackView: UIStackView = {
        return UIFactory_.makeStackView(arrangedSubviews: [hiddenIcon, deleteIcon], axis: .horizontal, spacing: 10)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()

        textField.delegate = self
        textField.keyboardType = UIKeyboardType.asciiCapable
        textField.textContentType = .newPassword
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(fieldStackView)
        fieldStackView.addSubview(textFieldStackView)
        
        textFieldStackView.addArrangedSubviews(fieldIcon, textField, buttonStackView)
        
        fieldStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        textFieldStackView.snp.makeConstraints {
              $0.edges.equalToSuperview()
          }
        
        fieldIcon.snp.makeConstraints {
            $0.width.equalTo(24)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.width.equalTo(58)
        }
        
        hiddenIcon.isUserInteractionEnabled = true
         let hiddenGesture = UITapGestureRecognizer(target: self, action: #selector(hiddenIconTapped))
        hiddenIcon.addGestureRecognizer(hiddenGesture)
        
        deleteIcon.isUserInteractionEnabled = true
         let deleteGesture = UITapGestureRecognizer(target: self, action: #selector(deleteIconTapped))
        deleteIcon.addGestureRecognizer(deleteGesture)
    }

    func configureField(placeholder: String, iconName: String) {
        textField.placeholder = placeholder
        fieldIcon.image = UIImage(named: iconName)
    }
    
    @objc private func hiddenIconTapped() {
        onHiddenIconTapped?()
    }
    
    @objc private func deleteIconTapped() {
        textField.text = ""  // Clear the text field
        onDeleteIconTapped?()
    }
}
