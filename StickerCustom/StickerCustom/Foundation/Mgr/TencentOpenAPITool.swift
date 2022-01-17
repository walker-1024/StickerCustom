//
//  TencentOpenAPITool.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2022/1/15.
//

import Foundation

class TencentOpenAPITool: NSObject, TencentSessionDelegate {

    static let shared = TencentOpenAPITool()

    private var tencentOAuth: TencentOAuth!

    private override init() {
        super.init()
        TencentOAuth.setIsUserAgreedAuthorization(true)
        tencentOAuth = TencentOAuth(appId: "101992634", andDelegate: self)

        guard let accessToken = UserConfigMgr.shared.getValue(of: .accessToken) as? String,
              let openId = UserConfigMgr.shared.getValue(of: .openId) as? String,
              let expirationDate = UserConfigMgr.shared.getValue(of: .expirationDate) as? Date
        else {
            return
        }
        tencentOAuth.accessToken = accessToken
        tencentOAuth.openId = openId
        tencentOAuth.expirationDate = expirationDate
    }

    func login() -> Bool {
        let permissions = [kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO]
        return tencentOAuth.authorize(permissions)
    }

    func tencentDidLogin() {
        print("===========================")
        print("did login")
        if let accessToken = tencentOAuth.accessToken {
            UserConfigMgr.shared.saveValue(accessToken, to: .accessToken)
        }
        if let openId = tencentOAuth.openId {
            UserConfigMgr.shared.saveValue(openId, to: .openId)
        }
        if let expirationDate = tencentOAuth.expirationDate {
            UserConfigMgr.shared.saveValue(expirationDate, to: .expirationDate)
        }
        print("===========================")
        tencentOAuth.getUserInfo()
    }

    func tencentDidNotLogin(_ cancelled: Bool) {
        print("===========================")
        print("did not login\(cancelled)")
        print("===========================")
    }

    func tencentDidNotNetWork() {
        print("===========================")
        print("did not network")
        print("===========================")
    }

    func getUserInfoResponse(_ response: APIResponse!) {
        print("===========================")
        print(response.message)
        print("===========================")
    }
}
