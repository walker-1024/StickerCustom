//
//  UIColorUtil.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/15.
//

import Foundation
import UIKit

extension UIColor {

    public convenience init(red: UInt8, green: UInt8, blue: UInt8) {
        self.init(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: 1)
    }

    static var backgroundDark:UIColor {
        return UIColor(red: 44, green: 48, blue: 51)
    }
    static var tintGreen:UIColor {
        return UIColor(red: 141, green: 248, blue: 159)
    }
}
