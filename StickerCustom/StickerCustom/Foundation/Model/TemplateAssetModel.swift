//
//  TemplateAssetModel.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/24.
//

import Foundation

struct TemplateAssetModel: Codable {
    enum AssetType: String, Codable {
        case png
        case gif
    }
    var templateId: String // 所属模板的 ID
    var name: String // 用户给文件的命名
    var data: Data // 文件数据
    var assetType: AssetType // 文件类型
    var time: String = Date().formatString // 此文件被添加的时间，格式为 YYYY-MM-dd HH:mm:ss
}
