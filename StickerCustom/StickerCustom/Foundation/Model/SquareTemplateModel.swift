//
//  SquareTemplateModel.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2022/1/22.
//

import Foundation

struct SquareTemplateModel: Codable {
    var templateId: UUID // 模板的唯一标识符
    var title: String // 模板的标题
    var code: String // 模板的 Ros 代码
    var coverUrl: URL? // 模板封面链接
    var author: String // 模板作者的 UID
    var downloadUrl: URL? // 模板下载链接
}
