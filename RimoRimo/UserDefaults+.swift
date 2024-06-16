//
//  UserDefaults+.swift
//  RimoRimo
//
//  Created by A Hyeon on 6/14/24.
//

import Foundation
extension UserDefaults {
  static var shared: UserDefaults {
    let appGroupId = "group.kr.xoul.RimoRimo"
    return UserDefaults(suiteName: appGroupId)!
  }
}
