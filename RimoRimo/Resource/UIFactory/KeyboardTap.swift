//
//  KeyboardTap.swift
//  RimoRimo-Refactoring
//
//  Created by wxxd-fxrest on 6/24/24.
//

import Foundation
import UIKit

//MARK: - 텍스트필드 키보드 관련 확장
extension UIViewController {
    // 화면을 탭했을 때 키보드를 숨기는 기능
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboardByTapGesture))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // 키보드가 보여질 때 호출되는 함수
    @objc func dismissKeyboardByTapGesture() {
        view.endEditing(true)
    }
    
    // 키보드의 상태 변화를 감지하는 옵저버 설정
    func setKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillShowByTapGesture), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillHideByTapGesture), name: UIResponder.keyboardWillHideNotification, object:nil)
    }
    
    // 키보드가 나타날 때 호출되는 함수
    @objc func keyboardWillShowByTapGesture(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            
            // 만약 뷰의 첫 번째 서브뷰가 UIScrollView일 경우
            if let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
                scrollView.contentInset = contentInsets
                scrollView.scrollIndicatorInsets = contentInsets
            } else {
                // UIScrollView가 아닌 경우, 뷰의 위치를 조정
                let bottomPadding = view.safeAreaInsets.bottom
                view.frame.origin.y = 0 - (keyboardHeight - bottomPadding)
            }
        }
    }
    
    // 키보드가 사라질 때 호출되는 함수
    @objc func keyboardWillHideByTapGesture(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        
        // 만약 뷰의 첫 번째 서브뷰가 UIScrollView일 경우
        if let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        } else {
            // UIScrollView가 아닌 경우, 뷰의 위치를 원래대로 복귀
            view.frame.origin.y = 0
        }
    }
}
