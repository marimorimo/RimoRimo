//
//  ActivityIndicatorHelper.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/29/24.
//

import UIKit

class ActivityIndicatorHelper: UIView {
    var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubviews(activityIndicator)
        setupActivityIndicator()
    }
    
    private func setupActivityIndicator() {
        activityIndicator.color = MySpecialColors.MainColor
        
        activityIndicator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}
