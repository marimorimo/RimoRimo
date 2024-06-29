//
//  AlertOnboarding.swift
//  MarimoMainTimer
//
//  Created by wxxd-fxrest on 6/20/24.
//

import UIKit
import SnapKit

class AlertOnboarding {
    private let onboardingBackView = AlertUIFactory.alertBackView()
    private let onboardingView = AlertUIFactory.alertView()
    private let onboardingText: UILabel
    
    init(onboardingText: String) {
        self.onboardingText = AlertUIFactory.alertSubTitle(subTitleText: onboardingText, textColor: MySpecialColors.Gray4, fontSize: 14)
    }
    
    func setAlertView(in viewController: UIViewController) {
        guard let view = viewController.view else {
            return
        }
        
        view.addSubview(onboardingBackView)
        onboardingBackView.addSubview(onboardingView)
        onboardingView.addSubview(onboardingText)
        
        setupConstraints(in: view)
        
        onboardingBackView.alpha = 0.0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.onboardingBackView.alpha = 1.0
        }) { _ in
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                UIView.animate(withDuration: 0.5, animations: {
                    self.onboardingBackView.alpha = 0.0
                }) { _ in
                    self.onboardingBackView.removeFromSuperview()
                }
            }
        }
    }

    func setupConstraints(in view: UIView) {
        onboardingBackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        onboardingView.snp.makeConstraints {
            $0.centerY.equalTo(onboardingBackView.snp.centerY)
            $0.leading.trailing.equalTo(onboardingBackView).inset(46)
        }
        
        onboardingText.snp.makeConstraints {
            $0.top.equalTo(onboardingView.snp.top).offset(16)
            $0.bottom.equalTo(onboardingView.snp.bottom).offset(-16)
            $0.centerX.equalTo(onboardingView.snp.centerX)
        }
    }
}
