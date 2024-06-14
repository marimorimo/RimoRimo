
import Foundation

extension UserDefaults {
    static var shared: UserDefaults {
        let appGroupId = "group.kr.xoul.RimoRimo"
        return UserDefaults(suiteName: appGroupId)!
    }
}
