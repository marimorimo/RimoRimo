//
//  SuccessView.swift
//  RimoRimo-Refactoring
//
//  Created by wxxd-fxrest on 6/28/24.
//

import UIKit

class SuccessView: UIView {
    
    // MARK: - Properties
    private let successView = UIView().then {
        $0.backgroundColor = MySpecialColors.Blue.withAlphaComponent(0.6)
        $0.layer.cornerRadius = 24
        $0.clipsToBounds = true
    }
    
    private let successStackView = UIStackView().then {
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 10
    }
    
    private let successTitleLabel = UILabel().then {
        $0.text = "마리모의 성장이 완료되었어요!"
        $0.textColor = MySpecialColors.Black
        $0.font = UIFont.pretendard(style: .bold, size: 18)
    }
    
    private let goDetailImage = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = MySpecialColors.Black
    }
    
    private let successTextLabel = UILabel().then {
        $0.text = """
        마리모가 생성되었습니다!
        성장이 완료된 마리모를 확인해 보세요.
        """
        $0.textColor = MySpecialColors.Black
        $0.font = UIFont.pretendard(style: .regular, size: 14, isScaled: true)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    lazy var goDetailButton = UIButton()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(successView)
        
        successView.addSubviews(successStackView, successTitleLabel, goDetailImage, successTextLabel, goDetailButton)
        
        setupSuccessView()
    }
    
    private func setupSuccessView() {
        successView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }

        successStackView.snp.makeConstraints {
            $0.top.equalTo(successView).offset(20)
            $0.leading.equalTo(successView).offset(24)
            $0.trailing.equalTo(successView).offset(-24)
            $0.height.equalTo(18)
        }

        successTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(successStackView)
            $0.leading.equalTo(successStackView)
        }

        goDetailImage.snp.makeConstraints {
            $0.centerY.equalTo(successStackView)
            $0.trailing.equalTo(successStackView)
            $0.width.equalTo(14)
            $0.height.equalTo(18)
        }

        successTextLabel.snp.makeConstraints {
            $0.top.equalTo(successStackView.snp.bottom).offset(8)
            $0.leading.equalTo(successView).offset(24)
            $0.trailing.equalTo(successView).offset(-24)
            $0.bottom.equalTo(successView).offset(-20)
        }

        goDetailButton.snp.makeConstraints {
            $0.edges.equalTo(successView)
        }
    }
}
