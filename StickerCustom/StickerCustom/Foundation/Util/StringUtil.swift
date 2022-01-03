//
//  StringUtil.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/15.
//

import Foundation
import UIKit

extension String {

    var localized: String {
        return Bundle.main.localizedString(forKey: self, value: nil, table: nil)
    }

    var localImage: UIImage? {
        return UIImage(named: self)
    }

    subscript(i: Int) -> String {
        let begin = self.index(self.startIndex, offsetBy: i)
        return String(self[begin])
    }

    subscript(range: Range<Int>) -> String {
        let begin = self.index(self.startIndex, offsetBy: range.lowerBound)
        let end = self.index(self.startIndex, offsetBy: range.upperBound)
        return String(self[begin..<end])
    }

    var isIntNumber: Bool {
        let scanner = Scanner(string: self)
        return scanner.scanInt() != nil && scanner.isAtEnd
    }

    var isFloatNumber: Bool {
        let scanner = Scanner(string: self)
        return scanner.scanFloat() != nil && scanner.isAtEnd
    }

    func firstIndex(of string: String) -> Int {
        guard string.count > 0 else { return -1 }
        for i in 0...(self.count - string.count) {
            if self[i] == string[0] {
                var flag = true
                for index in 1..<string.count {
                    if self[i + index] != string[index] {
                        flag = false
                        break
                    }
                }
                if flag {
                    return i
                }
            }
        }
        return -1
    }
}
