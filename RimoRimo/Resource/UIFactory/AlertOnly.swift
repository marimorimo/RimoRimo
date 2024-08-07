//
//  AlertOnlyViewController.swift
//  MarimoMainTimer
//
//  Created by wxxd-fxrest on 6/16/24.
//

import UIKit

class AlertOnly: NSObject {
    private let alertBack = AlertUIFactory.alertBackView()
    private let alertView = AlertUIFactory.alertView()
    private let widthLine = AlertUIFactory.widthLine()
    private let checkView = AlertUIFactory.checkView()
    
    private let alertTitle: UILabel
    private let alertSubTitle: UILabel
    private let checkLabel: UILabel
    
    var completionHandler: (() -> Void)?
    
    override init() {
        self.alertTitle = AlertUIFactory.alertTitle(titleText: "차단 해제", textColor: MySpecialColors.Black, fontSize: 16)
        self.alertSubTitle = AlertUIFactory.alertSubTitle(subTitleText: "차단을 해제하시겠습니까?", textColor: MySpecialColors.Gray4, fontSize: 14)
        self.checkLabel = AlertUIFactory.checkLabel(cancleText: "확인", textColor: MySpecialColors.MainColor, fontSize: 14)
        
        super.init()
    }
    
    @objc func checkLabelTapped() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alertBack.alpha = 0
            self.alertView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            self.alertBack.removeFromSuperview()
            self.completionHandler?() 
        }
    }
    
    func setAlertView(title: String, subTitle: String, in viewController: UIViewController) {
        alertTitle.text = title
        alertSubTitle.text = subTitle
        
        checkView.isUserInteractionEnabled = true
        
        viewController.view.addSubview(alertBack)
        alertBack.addSubviews([alertView])
        alertView.addSubviews([alertTitle, alertSubTitle, widthLine, checkView])
        checkView.addSubviews([checkLabel])
        
        setupConstraints(in: viewController.view)
        
        alertBack.alpha = 0
        alertView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        
        UIView.animate(withDuration: 0.3) {
            self.alertBack.alpha = 1
            self.alertView.transform = CGAffineTransform.identity
        }
        
        checkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkLabelTapped)))
    }
    
    private func setupConstraints(in view: UIView) {
        alertBack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        alertView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(46)
            $0.height.equalTo(140)
        }
        
        alertTitle.snp.makeConstraints {
            $0.top.equalTo(alertView).offset(24)
            $0.centerX.equalTo(alertView)
        }
        
        alertSubTitle.snp.makeConstraints {
            $0.top.equalTo(alertTitle.snp.bottom).offset(10)
            $0.centerX.equalTo(alertView)
        }
        
        widthLine.snp.makeConstraints {
            $0.top.equalTo(alertSubTitle.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(alertView).inset(0)
            $0.height.equalTo(0.5)
        }
        
        checkView.snp.makeConstraints {
            $0.top.equalTo(widthLine.snp.bottom)
            $0.leading.trailing.bottom.equalTo(alertView)
        }
        
        checkLabel.snp.makeConstraints {
            $0.top.equalTo(checkView).offset(14)
            $0.centerX.equalTo(checkView)
        }
    }
}

//        alertOnly.setAlertView(title: "차단 해제", subTitle: "차단을 해제하시겠습니까?", in: self)
