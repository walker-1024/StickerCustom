//
//  TemplateModel.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/16.
//

import Foundation

struct TemplateModel: Codable {
    var templateId: UUID = UUID() // 模板的唯一标识符
    var title: String // 模板的标题
    var code: String // 模板的 Ros 代码
    var cover: Data? // 模板的封面图片
    var author: String // 模板作者的 UID
    var downloadUrl: URL? // 模板下载链接，仅在广场上拉取到的模板里使用
}
