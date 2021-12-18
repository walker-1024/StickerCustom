//
//  TemplateModel.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/16.
//

import Foundation
import UIKit

struct TemplateModel: Codable {
    var image = "丢".localImage?.pngData()
    var code: String
}
