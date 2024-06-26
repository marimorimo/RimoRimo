//
//  UserModel.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/25/24.
//

import Foundation

struct User {
    var email: String
    var password: String
    var nickname: String
}

class UserModel {

    static let shared = UserModel()

    private let saveAutoLoginInfo = "userEmail"

    private init() {}

    func saveUserEmail(_ email: String) {
        UserDefaults.standard.set(email, forKey: saveAutoLoginInfo)
    }

    func getUserEmail() -> String? {
        return UserDefaults.standard.string(forKey: saveAutoLoginInfo)
    }

    func clearUserEmail() {
        UserDefaults.standard.removeObject(forKey: saveAutoLoginInfo)
    }
}
