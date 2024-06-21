import Foundation

extension UserDefaults {
    static var shared: UserDefaults {
        let appGroupId = "group.com.teamremo.RimoRimo"
        return UserDefaults(suiteName: appGroupId)!
    }
}
