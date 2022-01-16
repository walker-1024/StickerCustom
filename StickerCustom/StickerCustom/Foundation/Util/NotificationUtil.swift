//
//  NotificationUtil.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/15.
//

import Foundation

extension Notification.Name {
    static var needRefreshProfile: Self {
        return Notification.Name("SCNotification_NeedRefreshProfile")
    }

    static var needRefreshTemplateList: Self {
        return Notification.Name("SCNotification_NeedRefreshTemplateList")
    }
}
