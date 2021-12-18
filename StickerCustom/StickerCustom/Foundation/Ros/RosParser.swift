//
//  RosParser.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/17.
//

import Foundation

class RosParser {

    static let shared = RosParser()

    private init() { }

    func parse(code: String) {

    }
}

let RosReservedWordsEnglish: [String] = [
    "for"
]

let RosReservedWordsChinese: [String] = [
    "循环"
]

enum RosFunctionEnglish: String {
    case Ros_for = "for"
}

enum RosFunctionChinese: String {
    case Ros_for = "循环"
}

fileprivate class RosEnvironment {

    private var variables: [String: Any] = [:]

    func isExistVar(_ name: String) -> Bool {
        return variables.keys.contains(name)
    }

    func getVarValue(_ name: String) -> Any? {
        return variables[name]
    }

    func setVarValue(_ name: String, value: Any) {
        variables[name] = value
    }
}

fileprivate class RosSentence {

    var code: String
    weak var env: RosEnvironment?

    init(code: String, env: RosEnvironment?) {
        self.code = code
        self.env = env
    }

    @discardableResult
    func evaluate() -> (Any?, RosParseError?) {
        code.removeAll(where: { $0 == " " })
        if !code.hasPrefix("{") || !code.hasSuffix("}") {
            // 如果是变量的话，返回变量的值
            if self.env?.isExistVar(code) ?? false {
                return (self.env?.getVarValue(code), nil)
            } else {
                return (code, nil)
            }
        }
        var arr: [String] = []
        var lastIndex = 1
        for i in 1..<code.count - 1 {
            if code[i] == "," || code[i] == "，" {
                arr.append(code[lastIndex..<i])
                lastIndex = i + 1
            }
        }
        if arr.count == 0 || arr[0].count == 0 {
            return (nil, .functionNameNull)
        }
        guard let rosFunc = RosFunctionChinese(rawValue: arr[0]) else {
            return (nil, .funcNameNotExist)
        }
        arr.removeFirst()
        return evaluateRosFunc(rosFunc, paras: arr)
    }

    private func evaluateRosFunc(_ rosFunc: RosFunctionChinese, paras: [String]) -> (Any?, RosParseError?) {
        switch rosFunc {
        case .Ros_for:
            if paras.count < 2 { return (nil, .paramMissing) }
            if paras.count > 2 { return (nil, .paramRedundant) }
            let (num, err) = RosSentence(code: paras[0], env: self.env).evaluate()
            if err != nil { return (nil, err) }
            if let numStr = num as? String, let num = Int(numStr) {
                for _ in 0..<num {
                    RosSentence(code: paras[1], env: self.env).evaluate()
                }
            } else if let num = num as? NSNumber {
                for _ in 0..<num.intValue {
                    RosSentence(code: paras[1], env: self.env).evaluate()
                }
            } else {
                return(nil, .paramTypeMismatch)
            }
        }




        return (nil, .placeholder)
    }
}

/// 语法处理的错误类型
enum RosParseError: Error {
    /// 函数名为空
    ///
    /// 
    case functionNameNull
    /// 函数不存在
    ///
    /// 此函数名不在函数字典里
    case funcNameNotExist
    /// 参数类型不匹配
    ///
    /// 一个函数传入的某个参数的类型无法被转换成所需要的类型
    case paramTypeMismatch
    /// 参数缺失
    ///
    /// 一个函数传入的参数数量少于所需数量
    case paramMissing
    /// 参数多余
    ///
    /// 一个函数传入的参数数量多于所需数量
    case paramRedundant
    case placeholder
}
