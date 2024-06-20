//
//  AlertPaths.swift
//  MarimoMainTimer
//
//  Created by 밀가루 on 6/20/24.
//

import UIKit
import SnapKit

class AlertPaths: NSObject {
    
    private let alertBack = AlertUIFactory.alertBackView()
    private let alertView = AlertUIFactory.alertView()
    private let widthLine = AlertUIFactory.widthLine()
    private let heightLine = AlertUIFactory.heightLine()
    private let cancleView = AlertUIFactory.cancleView()
    private let checkView = AlertUIFactory.checkView()
    
    private let alertTitle: UILabel
    private let alertSubTitle: UILabel
    private let cancleLabel: UILabel
    private let checkLabel: UILabel
    
    override init() {
        self.alertTitle = AlertUIFactory.alertTitle(titleText: "차단 해제", textColor: MySpecialColors.Black, fontSize: 16)
        self.alertSubTitle = AlertUIFactory.alertSubTitle(subTitleText: "차단을 해제하시겠습니까?", textColor: MySpecialColors.Gray4, fontSize: 14)
        self.checkLabel = AlertUIFactory.checkLabel(cancleText: "확인", textColor: MySpecialColors.MainColor, fontSize: 14)
        self.cancleLabel = AlertUIFactory.cancleLabel(cancleText: "취소", textColor: MySpecialColors.Red, fontSize: 14)
        
        super.init()
    }
    
    var confirmHandler: (() -> Void)?
    var cancelHandler: (() -> Void)?
    
    @objc private func handleCancelTap() {
        dismissAlert()
        cancelHandler?()
    }
    
    @objc private func handleConfirmTap() {
        dismissAlert()
        confirmHandler?()
    }
    
    private func dismissAlert() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alertBack.alpha = 0
            self.alertView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            self.alertBack.removeFromSuperview()
        }
    }
    
    func setAlertView(title: String, subTitle: String, in viewController: UIViewController) {
        alertTitle.text = title
        alertSubTitle.text = subTitle
        
        checkView.isUserInteractionEnabled = true
        
        viewController.view.addSubview(alertBack)
        alertBack.addSubviews([alertView])
        alertView.addSubviews([alertTitle, alertSubTitle, widthLine, heightLine, checkView, cancleView])
        checkView.addSubviews([checkLabel, cancleLabel])
        
        setupConstraints(in: viewController.view)
        
        alertBack.alpha = 0
        alertView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        
        UIView.animate(withDuration: 0.3) {
            self.alertBack.alpha = 1
            self.alertView.transform = CGAffineTransform.identity
        }
        
        let cancelTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCancelTap))
        cancleView.addGestureRecognizer(cancelTapGesture)
        
        let confirmTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleConfirmTap))
        checkView.addGestureRecognizer(confirmTapGesture)
    }
    
    private func setupConstraints(in view: UIView) {
        alertBack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        alertView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(46)
            make.height.equalTo(140)
        }
        
        alertTitle.snp.makeConstraints { make in
            make.top.equalTo(alertView).offset(24)
            make.centerX.equalTo(alertView)
        }
        
        alertSubTitle.snp.makeConstraints { make in
            make.top.equalTo(alertTitle.snp.bottom).offset(10)
            make.centerX.equalTo(alertView)
        }
        
        widthLine.snp.makeConstraints { make in
            make.top.equalTo(alertSubTitle.snp.bottom).offset(20)
            make.leading.trailing.equalTo(alertView).inset(0)
            make.height.equalTo(0.5)
        }
        
        heightLine.snp.makeConstraints {
            $0.top.equalTo(widthLine.snp.bottom)
            $0.centerX.equalTo(alertView.snp.centerX)
            $0.width.equalTo(0.5)
            $0.height.equalTo(80)
        }
        
        cancleView.snp.makeConstraints {
            $0.top.equalTo(widthLine.snp.bottom)
            $0.leading.equalTo(alertView.snp.leading)
            $0.trailing.equalTo(heightLine.snp.leading).offset(-4)
            $0.bottom.equalTo(alertView.snp.bottom)
        }

        cancleLabel.snp.makeConstraints {
            $0.top.equalTo(cancleView.snp.top).offset(14)
            $0.centerX.equalTo(cancleView.snp.centerX)
        }

        checkView.snp.makeConstraints {
            $0.top.equalTo(widthLine.snp.bottom)
            $0.leading.equalTo(heightLine.snp.trailing).offset(4)
            $0.trailing.equalTo(alertView.snp.trailing)
            $0.bottom.equalTo(alertView.snp.bottom)
        }

        checkLabel.snp.makeConstraints {
            $0.top.equalTo(checkView.snp.top).offset(14)
            $0.centerX.equalTo(checkView.snp.centerX)
        }
    }
}
