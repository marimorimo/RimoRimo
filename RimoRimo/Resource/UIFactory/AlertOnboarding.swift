//
//  AlertOnboarding.swift
//  MarimoMainTimer
//
//  Created by 밀가루 on 6/20/24.
//

import UIKit
import SnapKit

class AlertOnboarding {
    private let onboardingBackView = AlertUIFactory.alertBackView()
    private let onboardingView = AlertUIFactory.alertView()
    private let onboardingText: UILabel
    
    init() {
        self.onboardingText = AlertUIFactory.alertSubTitle(subTitleText: "자정(12시) 전에 꼭 집중 모드를 중단해 주세요!", textColor: MySpecialColors.Gray4, fontSize: 14)
    }
    
    func setAlertView(in viewController: UIViewController) {
        guard let view = viewController.view else {
            print("ViewController's view is not ready.")
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
        onboardingBackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        onboardingView.snp.makeConstraints { make in
            make.centerY.equalTo(onboardingBackView.snp.centerY)
            make.leading.trailing.equalTo(onboardingBackView).inset(46)
        }
        
        onboardingText.snp.makeConstraints { make in
            make.top.equalTo(onboardingView.snp.top).offset(16)
            make.bottom.equalTo(onboardingView.snp.bottom).offset(-16)
            make.centerX.equalTo(onboardingView.snp.centerX)
        }
    }
}
