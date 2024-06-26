//
//  PrivacyPolicyViewController.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/20/24.
//

import UIKit
import MarkdownView

class PrivacyPolicyViewController: UIViewController {

    private let markdownView: MarkdownView = {
        let mark = MarkdownView()
        mark.isScrollEnabled = true
        return mark
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MySpecialColors.Gray1

        setupNavigationBar()
        setupMarkdownView()
    }

    // MARK: - Setup Navigation Bar
    private func setupNavigationBar() {
        title = "개인정보 처리 방침"
        navigationController?.navigationBar.topItem?.title = ""
        navigationController?.navigationBar.tintColor = MySpecialColors.MainColor
    }

    // MARK: - Setup Markdown View
    private func setupMarkdownView() {
        view.addSubview(markdownView)
        
        markdownView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            markdownView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            markdownView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            markdownView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            markdownView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let markdownText = """
        ### 총칙
        <middle>[리모리모]('이하 "회사"')는 사용자의 개인정보를 중요시하며, "개인정보 보호법"을 준수하고 있습니다. 본 개인정보처리 방침은 회사가 제공하는 [리모리모]('이하 "서비스"')를 이용함에 있어 사용자의 개인정보가 어떻게 수집, 이용, 제공되는지에 대해 설명합니다.</middle>

        
        ### 수집하는 개인정보 항목
        <middle>회사는 다음과 같은 개인정보를 수집하고 있습니다.</middle>
        <small>개인정보 항목: 이메일 주소</small>
        <small>수집 방법: 회원가입 시 사용자 입력</small>
        
        
        ### 개인정보의 수집 및 이용 목적
        <middle>회사는 수집한 개인정보를 다음의 목적을 위해 활용합니다.</middle>
        <small>* 서비스 제공 및 운영</small>
        <small>* 사용자 맞춤형 서비스 제공</small>
        <small>* 고객 지원 및 문의 응대</small>
        <small>* 서비스 개선을 위한 통계 분석</small>
        
        
        ### 개인정보의 보유 및 이용 기간
        <middle>회사는 서비스 이용 기간 동안 보유하며, 회원 탈퇴 시 지체 없이 파기합니다. 단, 법령에 따라 보존해야 하는 경우에는 해당 기간 동안 보존합니다.</middle>
        
        
        ### 개인정보의 제3자 제공
        <middle>회사는 사용자의 개인정보를 원칙적으로 외부에 제공하지 않습니다. 다만, 아래의 경우에는 예외로 합니다.</middle>
        <small>* 사용자가 사전에 동의한 경우</small>
        <small>* 법령의 규정에 의거하거나, 수사 목적으로 법령에 정해진 절차와 방법에 따라 수사기관의 요구가 있는 경우</small>

        
        ### 개인정보 처리 위탁
        <middle>회사는 개인정보를 처리 위탁하지 않습니다.</middle>
        
        
        ### 사용자의 권리 및 행사 방법
        <middle>사용자는 언제든지 자신의 개인 정보에 대해 조회, 수정, 삭제, 처리 정지 등을 요청할 수 있습니다. 이러한 요청은 [고객 지원 이메일]를 통해 할 수 있습니다.</middle>

        
        ### 타사 모듈 사용에 대한 안내
        <middle>탑재된 타사 서비스 모듈은 없습니다.</middle>

        
        ### 쿠키의 사용
        <middle>회사는 서비스 쿠키를 사용하지 않으며 이용하지 않습니다. 이용자가 이에 대해 의문이 있다면 해당 서비스(애플 및 각 광고 미디어)로 직접 연락해야 합니다.</middle>

        
        ### 개인정보 보호 책임자
        <middle>본 개인정보처리 정책에 대해 궁금하신 사항이 있거나, 개인정보 처리 절차에 대한 질문, 의견 또는 우려가 있을 경우 아래 연락처로 연락 주시기 바랍니다.</middle>

        이메일: rimorimocompany@gmail.com

        """
        
        markdownView.load(markdown: markdownText,
                          css: """
                                small {
                                  font-size: 12px;
                                }
                                middle {
                                  font-size: 14px;
                                }
                               """
        )
    }
}
