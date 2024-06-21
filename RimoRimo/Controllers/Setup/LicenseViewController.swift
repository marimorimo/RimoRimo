//
//  LicenseViewController.swift
//  RimoRimo
//
//  Created by 이유진 on 6/21/24.
//

import UIKit
import MarkdownView

class LicenseViewController: UIViewController {

    private let markdownView: MarkdownView = {
        let mark = MarkdownView()
        mark.isScrollEnabled = true
        return mark
    }()
    
    // MARK: - PrivacyPolicyView
    private let privacyPolicyView: UIView = {
        let view = UIView()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MySpecialColors.Gray1

        setupNavigationBar()
        setupMarkdownView()
    }

    // MARK: - Setup Navigation Bar
    private func setupNavigationBar() {
        title = "라이선스"
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
            markdownView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
        
        let markdownText = """
        #### 아이콘
        <small>Icons by Kryston Schwarze from Coolicons, licensed under CC BY 4.0.
                <small>© 2024 Coolicons. This work is licensed under a Creative Commons Attribution 4.0 International License.
                <small>https://github.com/krystonschwarze/coolicons
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
    }}
