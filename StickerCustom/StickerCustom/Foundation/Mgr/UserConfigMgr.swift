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
        case token
        case username
        case UID
        // TencentOpenAPI 相关
        case accessToken
        case openId
        case expirationDate
        // Apple ID 登录相关
        case userIdentifier
    }

    func getValue(of config: UserConfig) -> Any? {
        return ud.value(forKey: config.rawValue)
    }

    func saveValue(_ value: Any, to config: UserConfig) {
        ud.setValue(value, forKey: config.rawValue)
    }

    func removeValue(of config: UserConfig) {
        ud.removeObject(forKey: config.rawValue)
    }

    func logout() {
        removeValue(of: .token)
        removeValue(of: .username)
        removeValue(of: .UID)
        removeValue(of: .accessToken)
        removeValue(of: .openId)
        removeValue(of: .expirationDate)
        removeValue(of: .userIdentifier)
    }

    private var globalValue: [String: Any] = [:]

    enum GlobalKey: String {
        case qqNum
    }

    func getValue(of key: GlobalKey) -> Any? {
        return globalValue[key.rawValue]
    }

    func saveValue(_ value: Any, to key: GlobalKey) {
        globalValue[key.rawValue] = value
    }

    func removeValue(of key: GlobalKey) {
        globalValue.removeValue(forKey: key.rawValue)
    }
}
