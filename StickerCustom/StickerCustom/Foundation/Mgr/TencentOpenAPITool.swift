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

    func isSupportQQLogin() -> Bool {
        // 判断当前手机是否已安装QQ或者TIM
        return QQApiInterface.isSupportShareToQQ()
    }

    func login() -> Bool {
        /*
         kOPEN_PERMISSION_GET_USER_INFO    获取用户信息
         kOPEN_PERMISSION_GET_SIMPLE_USER_INFO    移动端获取用户信息
         kOPEN_PERMISSION_GET_INFO    获取登录用户自己的详细信息
         kOPEN_PERMISSION_GET_VIP_RICH_INFO    获取会员用户详细信息
         kOPEN_PERMISSION_GET_VIP_INFO    获取会员用户基本信息
         kOPEN_PERMISSION_GET_OTHER_INFO    获取其他用户的详细信息
         kOPEN_PERMISSION_ADD_TOPIC    发表一条说说到QQ空间 (需要申请权限)
         kOPEN_PERMISSION_ADD_ONE_BLOG    发表一篇日志到QQ空间 (需要申请权限)
         kOPEN_PERMISSION_ADD_ALBUM    创建一个QQ空间相册 (需要申请权限)
         kOPEN_PERMISSION_UPLOAD_PIC    上传一张照片到QQ空间相册 (需要申请权限)
         kOPEN_PERMISSION_LIST_ALBUM    获取用户QQ空间相册列表 (需要申请权限)
         kOPEN_PERMISSION_CHECK_PAGE_FANS    验证是否认证空间粉丝
         */
        let permissions = [kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO]
        return tencentOAuth.authorize(permissions)
    }

    func getUserInfo() -> Bool {
        return tencentOAuth.getUserInfo()
    }

    // MARK: TencentSessionDelegate

    func tencentDidLogin() {
        guard let accessToken = tencentOAuth.accessToken else { return }
        guard let openId = tencentOAuth.openId else { return }
        guard let expirationDate = tencentOAuth.expirationDate else { return }
        UserConfigMgr.shared.saveValue(accessToken, to: .accessToken)
        UserConfigMgr.shared.saveValue(openId, to: .openId)
        UserConfigMgr.shared.saveValue(expirationDate, to: .expirationDate)
        NotificationCenter.default.post(name: .qqLoginSuccess, object: self, userInfo: ["openId": openId])
        tencentOAuth.getUserInfo()
    }

    func tencentDidNotLogin(_ cancelled: Bool) {

    }

    func tencentDidNotNetWork() {

    }

    func getUserInfoResponse(_ response: APIResponse!) {
        /*
         ret    返回码
         msg    如果ret<0，会有相应的错误信息提示，返回数据全部用UTF-8编码。
         nickname    用户在QQ空间的昵称。
         figureurl    大小为30×30像素的QQ空间头像URL。
         figureurl_1    大小为50×50像素的QQ空间头像URL。
         figureurl_2    大小为100×100像素的QQ空间头像URL。
         figureurl_qq_1    大小为40×40像素的QQ头像URL。
         figureurl_qq_2    大小为100×100像素的QQ头像URL。需要注意，不是所有的用户都拥有QQ的100x100的头像，但40x40像素则是一定会有。
         gender    性别。 如果获取不到则默认返回"男"

         以上是旧文档里的说明。实测发现还有以下字段。

         is_lost    0
         gender_type    2
         province
         city
         year    "2006"
         constellation
         figureurl_qq    猜测是640×640像素的QQ头像URL
         figureurl_type    "1"
         is_yellow_vip    "0"
         vip    "0"
         yellow_vip_level    "0"
         level    "0"
         is_yellow_year_vip    "0"
         */
        guard let dic = response.jsonResponse else { return }
        let name = dic["nickname"] as? String
        var avatarUrl = URL(string: dic["figureurl_qq"] as? String ?? "")
        if avatarUrl == nil {
            avatarUrl = URL(string: dic["figureurl_qq_2"] as? String ?? "")
        }
        if avatarUrl == nil {
            avatarUrl = URL(string: dic["figureurl_qq_1"] as? String ?? "")
        }
        let userInfo: [String : Any] = [
            "name": name as Any,
            "avatarUrl": avatarUrl as Any
        ]
        NotificationCenter.default.post(name: .getQQUserInfoSuccess, object: self, userInfo: userInfo)
    }
}
