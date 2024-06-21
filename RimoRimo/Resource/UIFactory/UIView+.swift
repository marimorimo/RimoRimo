//
//  UIFactory+.swift
//  MarimoMainTimer
//
//  Created by 밀가루 on 6/16/24.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { self.addSubview($0) }
    }
    
    func addSubviews(_ views: [UIView]) {
        views.forEach { self.addSubview($0) }
    }
}

extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach { self.addArrangedSubview($0) }
    }
    
    func addArrangedSubviews(_ views: [UIStackView]) {
        _ = views.map { self.addArrangedSubview($0) }
    }
}
