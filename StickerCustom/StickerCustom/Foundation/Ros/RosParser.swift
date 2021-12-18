//
//  RosParser.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/17.
//

import Foundation
import UIKit

class RosParser {

    static let shared = RosParser()

    private init() { }

    func parse(code: String, qqnum: Int) {
        guard let url = URL(string: "http://q1.qlogo.cn/g?b=qq&nk=\(qqnum)&s=640") else {
            return
        }
        DispatchQueue.global().async {
            guard let avatarData = try? Data(contentsOf: url) else { return }
            guard let avatar = UIImage(data: avatarData) else { return }
            let env = RosEnvironment()
            env.setVarValue("头像", value: avatar)
            let (result, err) = RosSentence(code: code, env: env).evaluate()
            print(result as Any)
            print(err)
            NotificationCenter.default.post(name: .tmp, object: self, userInfo: ["result": result as Any])
        }
    }
}

let RosReservedWords: [String] = [
    "_Ros_context", // 打算把 _Ros_ 开头的都设为保留的关键字，不允许用户定义为变量名
]

enum RosFunctionEnglish: String {
    case Ros_for = "for"
}

enum RosFunctionChinese: String {
    case Ros_for = "循环"
    case Ros_createDrawBoard = "新建画板"
    case Ros_drawImage = "画图片"
    case Ros_clipToCircle = "图像圆角化"
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

    func removeVarValue(_ name: String) {
        variables.removeValue(forKey: name)
    }
}

fileprivate class RosSentence {

    var code: String
    weak var env: RosEnvironment?

    init(code: String, env: RosEnvironment?) {
        self.code = code
        self.env = env
    }

    func evaluate() -> (Any?, RosParseError?) {
        code.removeAll(where: { $0 == " " || $0 == "\n" })
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
        var numOfLeftBrace = 0
        for i in 1..<code.count - 1 {
            if code[i] == "{" {
                numOfLeftBrace += 1
            } else if code[i] == "}" {
                numOfLeftBrace -= 1
            } else if numOfLeftBrace == 0 {
                if code[i] == "," || code[i] == "，" {
                    arr.append(code[lastIndex..<i])
                    lastIndex = i + 1
                }
            }
            // 如果到最后了，就遇不到逗号了，需要手动把最后一部分加到 arr 里
            if i == code.count - 2 {
                arr.append(code[lastIndex..<i + 1])
                lastIndex = i + 1
            }
        }
        if numOfLeftBrace != 0 {
            return (nil, .wrongSentence)
        }
        print(arr)
        if arr.count == 0 || arr[0].count == 0 {
            return (nil, .functionNameNull)
        }
        if arr[0].hasPrefix("{") {
            // 如果按规范语法写，这里的 arr 是只有一项的
            var allSentences: [String] = []
            var lastIndex = 0
            var numOfLeftBrace = 0
            for item in arr {
                for i in 0..<item.count {
                    if item[i] == "{" {
                        numOfLeftBrace += 1
                    } else if item[i] == "}" {
                        numOfLeftBrace -= 1
                        if numOfLeftBrace == 0 {
                            allSentences.append(item[lastIndex..<i + 1])
                            lastIndex = i + 1
                        }
                    }
                }
            }
            for sentence in allSentences {
                let (_, error) = RosSentence(code: sentence, env: self.env).evaluate()
                if error != nil {
                    return (nil, error)
                }
            }
            return (nil, nil)
        } else {
            guard let rosFunc = RosFunctionChinese(rawValue: arr[0]) else {
                return (nil, .funcNameNotExist)
            }
            arr.removeFirst()
            return evaluateRosFunc(rosFunc, paras: arr)
        }
    }

    private func evaluateRosFunc(_ rosFunc: RosFunctionChinese, paras: [String]) -> (Any?, RosParseError?) {
        switch rosFunc {
        case .Ros_for:
            if paras.count < 2 { return (nil, .paramMissing) }
            if paras.count > 2 { return (nil, .paramRedundant) }
            let (num, err) = RosSentence(code: paras[0], env: self.env).evaluate()
            if err != nil { return (nil, err) }

            guard let num = getInt(from: num) else {
                return (nil, .paramTypeMismatch)
            }
            for _ in 0..<num {
                let (_, error) = RosSentence(code: paras[1], env: self.env).evaluate()
                if error != nil {
                    return (nil, error)
                }
            }

        case .Ros_createDrawBoard:
            if paras.count < 3 { return (nil, .paramMissing) }
            if paras.count > 3 { return (nil, .paramRedundant) }
            let (width, err) = RosSentence(code: paras[0], env: self.env).evaluate()
            if err != nil { return (nil, err) }
            let (height, err2) = RosSentence(code: paras[1], env: self.env).evaluate()
            if err2 != nil { return (nil, err2) }

            guard let width = getDouble(from: width), let height = getDouble(from: height) else {
                return (nil, .paramTypeMismatch)
            }
            var error: RosParseError?
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
            let image = renderer.image { context in
                self.env?.setVarValue("_Ros_context", value: context)
                (_, error) = RosSentence(code: paras[2], env: self.env).evaluate()
                self.env?.removeVarValue("_Ros_context")
            }
            if error != nil {
                return (nil, error)
            }
            return (image, nil)

        case .Ros_drawImage:
            if paras.count < 3 { return (nil, .paramMissing) }
            if paras.count == 4 { return (nil, .paramNumMismatch) }
            if paras.count > 5 { return (nil, .paramRedundant) }
            let (image, err) = RosSentence(code: paras[0], env: self.env).evaluate()
            if err != nil { return (nil, err) }
            let (pointX, err2) = RosSentence(code: paras[1], env: self.env).evaluate()
            if err2 != nil { return (nil, err2) }
            let (pointY, err3) = RosSentence(code: paras[2], env: self.env).evaluate()
            if err3 != nil { return (nil, err3) }

            guard let image = getUIImage(from: image) else {
                return (nil, .paramTypeMismatch)
            }
            guard let pointX = getDouble(from: pointX) else {
                return (nil, .paramTypeMismatch)
            }
            guard let pointY = getDouble(from: pointY) else {
                return (nil, .paramTypeMismatch)
            }
            guard let _ = self.env?.getVarValue("_Ros_context") as? UIGraphicsImageRendererContext else {
                return (nil, .drawBeforeCreateDrawBoard)
            }

            if paras.count == 3 {
                image.draw(at: CGPoint(x: pointX, y: pointY))
            } else {
                let (width, err4) = RosSentence(code: paras[3], env: self.env).evaluate()
                if err4 != nil { return (nil, err4) }
                let (height, err5) = RosSentence(code: paras[4], env: self.env).evaluate()
                if err5 != nil { return (nil, err5) }
                guard let width = getDouble(from: width) else {
                    return (nil, .paramTypeMismatch)
                }
                guard let height = getDouble(from: height) else {
                    return (nil, .paramTypeMismatch)
                }
                image.draw(in: CGRect(x: pointX, y: pointY, width: width, height: height))
            }

        case .Ros_clipToCircle:
            if paras.count < 1 { return (nil, .paramMissing) }
            if paras.count > 1 { return (nil, .paramRedundant) }
            let (image, err) = RosSentence(code: paras[0], env: self.env).evaluate()
            if err != nil { return (nil, err) }
            guard let image = getUIImage(from: image) else {
                return (nil, .paramTypeMismatch)
            }
            return (image.clipToCircleImage(), nil)

        }

        return (nil, nil)
    }

    private func getDouble(from value: Any?) -> Double? {
        if let numStr = value as? String {
            return Double(numStr)
        } else if let num = value as? NSNumber {
            return num.doubleValue
        }
        return nil
    }

    private func getInt(from value: Any?) -> Int? {
        if let numStr = value as? String {
            return Int(numStr)
        } else if let num = value as? NSNumber {
            return num.intValue
        }
        return nil
    }

    private func getUIImage(from value: Any?) -> UIImage? {
        if let img = value as? UIImage {
            return img
        } else if let str = value as? String {
            // TODO: 封装一个图片管理系统给用户使用
            return str.localImage
        }
        return nil
    }
}

/// 语法处理的错误类型
enum RosParseError: Error {
    /// 获取QQ头像失败
    ///
    ///
    case fetchQQAvatarFail
    /// 左右大括号数量不匹配
    ///
    ///
    case wrongSentence
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
    /// 参数数量不匹配
    ///
    /// 比如一个函数需要 3 个或 5 个参数，但用户给了 4 个
    case paramNumMismatch
    /// 画图等函数没有写在新建画板内
    ///
    /// 在画图时获取 context 失败
    case drawBeforeCreateDrawBoard
    case placeholder
}
