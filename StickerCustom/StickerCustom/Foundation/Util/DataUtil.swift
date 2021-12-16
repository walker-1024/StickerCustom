//
//  DataUtil.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/15.
//

import Foundation
import CryptoKit

extension Data {
    var md5: String {
        return Insecure.MD5.hash(data: self).map {
            String(format: "%02hhX", $0)
        }.joined()
    }
}
