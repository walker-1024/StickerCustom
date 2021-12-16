//
//  UserConfigMgr.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/15.
//

import Foundation

class UserConfigMgr {

    static let shared = UserConfigMgr()

    private let ud = UserDefaults()

    private init() { }

    enum UserConfig: String {
        case token = "token"
        case email = "email"
        case password = "password"
        case username = "username"
        case visitor = "visitor"
        case visitorEmail = "visitor-email"
        case visitorPassword = "visitor-password"
        case placeholder
    }

    func getValue(of config: UserConfig) -> Any {
        return ud.value(forKey: config.rawValue) as Any
    }

    func saveValue(_ value: Any, to config: UserConfig) {
        ud.setValue(value, forKey: config.rawValue)
    }

    func removeValue(of config: UserConfig) {
        ud.removeObject(forKey: config.rawValue)
    }
}
