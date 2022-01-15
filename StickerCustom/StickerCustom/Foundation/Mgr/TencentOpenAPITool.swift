//
//  TencentOpenAPITool.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2022/1/15.
//

import Foundation

class TencentOpenAPITool: NSObject, TencentSessionDelegate {

    static let shared = TencentOpenAPITool()

    var tencentOAuth: TencentOAuth!

    private override init() {
        super.init()
        TencentOAuth.setIsUserAgreedAuthorization(true)
        tencentOAuth = TencentOAuth(appId: "101992634", andDelegate: self)
    }

    func tencentDidLogin() {
        print("===========================")
        print("did login")
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
