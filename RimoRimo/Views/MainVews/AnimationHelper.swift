//
//  AnimationHelper.swift
//  RimoRimo-Refactoring
//
//  Created by 밀가루 on 6/29/24.
//

import UIKit

class AnimationHelper {
    static func addBouncingAnimation(to targetView: UIView) {
        let moveDistance: CGFloat = 30 // 이동 거리
        let duration: TimeInterval = 1.6
        let damping: CGFloat = 1
        let velocity: CGFloat = 0
        
        let animationKey = "bouncingAnimation"
        
        if targetView.layer.animation(forKey: animationKey) == nil {
            let animation = CABasicAnimation(keyPath: "transform.translation.y")
            animation.fromValue = 0
            animation.toValue = -moveDistance
            animation.duration = duration
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.autoreverses = true
            animation.repeatCount = .greatestFiniteMagnitude
            animation.isRemovedOnCompletion = false
            targetView.layer.add(animation, forKey: animationKey)
        }
    }
    
    static func removeBouncingAnimation(from targetView: UIView) {
        let animationKey = "bouncingAnimation"
        if targetView.layer.animation(forKey: animationKey) != nil {
            targetView.layer.removeAnimation(forKey: animationKey)
        }
    }
}
