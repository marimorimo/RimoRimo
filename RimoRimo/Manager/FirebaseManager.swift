//
//  FirebaseManager.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/25/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class FirebaseManager {
    
    static let shared = FirebaseManager()
    private lazy var auth = Auth.auth()
    private lazy var db = Firestore.firestore()
    
    private init() {}
    
    func signIn(withEmail email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        auth.signIn(withEmail: email, password: password, completion: completion)
    }
    
    func checkNicknameExists(nickname: String, completion: @escaping (Bool, Error?) -> Void) {
        db.collection("user-info").whereField("nickname", isEqualTo: nickname).getDocuments { (snapshot, error) in
            if let error = error {
                completion(false, error)
                return
            }
            
            if let snapshot = snapshot {
                completion(!snapshot.isEmpty, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    func checkEmailExists(_ email: String, completion: @escaping (Bool, Error?) -> Void) {
        let usersRef = db.collection("user-info")
        usersRef.whereField("email", isEqualTo: email).getDocuments { (snapshot, error) in
            if let error = error {
                completion(false, error)
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    func registerUser(email: String, password: String, nickname: String, isPrivacyPolicyChecked: Bool, completion: @escaping (Bool, Error?) -> Void) {
        auth.createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("회원가입 실패 \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            guard let uid = authResult?.user.uid else {
                completion(false, NSError(domain: "FirebaseManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to get user UID"]))
                return
            }
            
            let userData: [String: Any] = [
                "email": email,
                "nickname": nickname,
                "profile-image": "Group 5",
                "d-day-title": "",
                "d-day": "",
                "target-time": "7",
                "signup-areed": isPrivacyPolicyChecked
            ]
            
            self.db.collection("user-info").document(uid).setData(userData) { error in
                if let error = error {
                    print("회원가입 정보 저장 실패 \(error.localizedDescription)")
                    completion(false, error)
                } else {
                    print("회원가입 정보 저장 성공 \(email)")
                    completion(true, nil)
                }
            }
        }
    }
}
