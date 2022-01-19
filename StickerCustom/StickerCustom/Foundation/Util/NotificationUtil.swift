//
//  NotificationUtil.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/15.
//

import Foundation

extension Notification.Name {

    static var qqLoginSuccess: Self {
        return Notification.Name("SCNotification_QQLoginSuccess")
    }

    static var getQQUserInfoSuccess: Self {
        return Notification.Name("SCNotification_GetQQUserInfoSuccess")
    }

    static var needRefreshTemplateList: Self {
        return Notification.Name("SCNotification_NeedRefreshTemplateList")
    }
}
