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

    func parse(code: String, qqnum: Int, templateId: UUID, completion: ((Any?, RosParseError?) -> Void)?) {
        guard let url = URL(string: "http://q1.qlogo.cn/g?b=qq&nk=\(qqnum)&s=640") else {
            completion?(nil, RosParseError.fetchQQAvatarFail)
            return
        }
        DispatchQueue.global().async {
            guard let avatarData = try? Data(contentsOf: url) else {
                completion?(nil, RosParseError.fetchQQAvatarFail)
                return
            }
            guard let avatar = UIImage(data: avatarData)?.clipToCircleImage() else {
                completion?(nil, RosParseError.fetchQQAvatarFail)
                return
            }
            let env = RosEnvironment()
            env.setVarValue("头像", value: avatar)
            let assets = TemplateAssetMgr.shared.getAllAssets(of: templateId)
            for item in assets ?? [] {
                if let image = UIImage(data: item.data) {
                    env.setVarValue(item.name, value: image)
                }
            }
            do {
                let trueCode = "{\n\(code)\n}"
                try RosSentence(code: trueCode, env: env).evaluate()
                let result = env.getVarValue("_Ros_finalResult")
                if let image = result as? UIImage {
                    completion?(image, nil)
                } else if let result = result as? [UIImage] {
                    // 注意这里拿到的整数的单位是毫秒
                    let eachDuration = env.getVarValue("_Ros_gifFrameDuration") as? Int ?? 100
                    if let image = UIImage.animatedImage(with: result, duration: Double(eachDuration * result.count) / 1000) {
                        completion?(image, nil)
                    } else {
                        completion?(nil, RosParseError.createGifFail)
                    }
                } else {
                    completion?(nil, RosParseError.noResult)
                }
            } catch let err {
                completion?(nil, err as? RosParseError)
            }
        }
    }
}

// 打算把 _Ros_ 开头的都设为保留的关键字，不允许用户定义为变量名
let RosReservedWords: [String] = [
    "_Ros_context",
    "_Ros_gifFrames",
    "_Ros_finalResult",
    "_Ros_gifFrameDuration",
]

enum RosFunctionEnglish: String {
    case Ros_for = "for"
}

enum RosFunctionChinese: String {
    case Ros_for = "循环"
    case Ros_createDrawBoard = "新建画板"
    case Ros_drawImage = "画图片"
    case Ros_clipToCircle = "图像圆角化"
    case Ros_getImageWidth = "取图片宽度"
    case Ros_getImageHeight = "取图片高度"
    case Ros_getColor = "取颜色" // 未测试
    case Ros_createGif = "创建动图"
    case Ros_appendFrame = "添加帧"
    case Ros_setGifFrameDuration = "设置帧延迟"
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

    @discardableResult
    func evaluate() throws -> Any? {
        // 删去注释
        var lines = code.split(separator: "\n").compactMap({ String($0) })
        for i in 0..<lines.count {
            let index = lines[i].firstIndex(of: "//")
            if index != -1 {
                lines[i] = lines[i][0..<index]
            }
        }
        code = lines.joined()

        code.removeAll(where: { $0 == " " || $0 == "\n" })
        if !code.hasPrefix("{") || !code.hasSuffix("}") {
            // 如果是变量的话，返回变量的值
            if self.env?.isExistVar(code) ?? false {
                return self.env?.getVarValue(code)
            } else {
                // 在这种情况下，需要把类似 图片{i} 的语句转换为 图片0 的语句
                var arr: [String] = []
                var leftIndex = 0
                var numOfLeftBrace = 0
                for i in 0..<code.count {
                    if code[i] == "{" {
                        numOfLeftBrace += 1
                        if numOfLeftBrace == 1 {
                            arr.append(code[leftIndex..<i])
                            leftIndex = i
                        }
                    } else if code[i] == "}" {
                        numOfLeftBrace -= 1
                        if numOfLeftBrace < 0 {
                            throw RosParseError.wrongSentence
                        } else if numOfLeftBrace == 0 {
                            let value = try RosSentence(code: code[leftIndex..<i + 1], env: self.env).evaluate()
                            arr.append("\(value ?? "")")
                            leftIndex = i + 1
                        }
                    }
                }
                if numOfLeftBrace != 0 {
                    throw RosParseError.wrongSentence
                }

                if arr.count == 0 {
                    return code
                } else {
                    let res = arr.joined()
                    if self.env?.isExistVar(res) ?? false {
                        return self.env?.getVarValue(res)
                    } else {
                        return res
                    }
                }
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
                if numOfLeftBrace < 0 {
                    throw RosParseError.wrongSentence
                }
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
            throw RosParseError.wrongSentence
        }
        print(arr)
        if arr.count == 0 || arr[0].count == 0 {
            throw RosParseError.functionNameNull
        }
        if arr[0].hasPrefix("{") {
            // 这种情况表明这个 Ros 语句是一个包含多个 Ros 语句的代码块
            // 如果按规范语法写，这里的 arr 应该是只有一项的
            var allSentences: [String] = []
            for item in arr {
                var lastIndex = 0
                var numOfLeftBrace = 0
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
                if numOfLeftBrace != 0 {
                    throw RosParseError.wrongSentence
                }
            }
            for sentence in allSentences {
                try RosSentence(code: sentence, env: self.env).evaluate()
            }
            return nil
        } else if arr.count == 1 {
            // 这种情况表明这个 Ros 语句其实是一个变量
            if self.env?.isExistVar(arr[0]) ?? false {
                return self.env?.getVarValue(arr[0])
            } else {
                throw RosParseError.varNameNotExist
            }
        } else {
            // 这种情况表明这个 Ros 语句是一个普通的函数
            guard let rosFunc = RosFunctionChinese(rawValue: arr[0]) else {
                throw RosParseError.funcNameNotExist
            }
            arr.removeFirst()
            return try evaluateRosFunc(rosFunc, paras: arr)
        }
    }

    private func evaluateRosFunc(_ rosFunc: RosFunctionChinese, paras: [String]) throws -> Any? {
        switch rosFunc {
        case .Ros_for:
            if paras.count < 2 { throw RosParseError.paramMissing }
            if paras.count > 3 { throw RosParseError.paramRedundant }
            let num = try RosSentence(code: paras[0], env: self.env).evaluate()
            guard let num = getInt(from: num) else {
                throw RosParseError.paramTypeMismatch
            }

            if paras.count == 2 {
                for _ in 0..<num {
                    try RosSentence(code: paras[1], env: self.env).evaluate()
                }
            } else {
                let name = paras[1]
                for i in 0..<num {
                    self.env?.setVarValue(name, value: i)
                    try RosSentence(code: paras[2], env: self.env).evaluate()
                }
                self.env?.removeVarValue(name)
            }

        case .Ros_createDrawBoard:
            if paras.count < 3 { throw RosParseError.paramMissing }
            if paras.count > 3 { throw RosParseError.paramRedundant }
            let width = try RosSentence(code: paras[0], env: self.env).evaluate()
            let height = try RosSentence(code: paras[1], env: self.env).evaluate()

            guard let width = getDouble(from: width), let height = getDouble(from: height) else {
                throw RosParseError.paramTypeMismatch
            }
            var error: RosParseError?
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
            let image = renderer.image { context in
                self.env?.setVarValue("_Ros_context", value: context)
                do {
                    try RosSentence(code: paras[2], env: self.env).evaluate()
                } catch let err {
                    error = err as? RosParseError
                }
                self.env?.removeVarValue("_Ros_context")
            }
            if error != nil { throw error! }
            self.env?.setVarValue("_Ros_finalResult", value: image)
            return image

        case .Ros_drawImage:
            if paras.count < 3 { throw RosParseError.paramMissing }
            if paras.count == 4 { throw RosParseError.paramNumMismatch }
            if paras.count > 5 { throw RosParseError.paramRedundant }
            let image = try RosSentence(code: paras[0], env: self.env).evaluate()
            let pointX = try RosSentence(code: paras[1], env: self.env).evaluate()
            let pointY = try RosSentence(code: paras[2], env: self.env).evaluate()

            guard let image = getUIImage(from: image) else {
                throw RosParseError.paramTypeMismatch
            }
            guard let pointX = getDouble(from: pointX) else {
                throw RosParseError.paramTypeMismatch
            }
            guard let pointY = getDouble(from: pointY) else {
                throw RosParseError.paramTypeMismatch
            }
            guard let _ = self.env?.getVarValue("_Ros_context") as? UIGraphicsImageRendererContext else {
                throw RosParseError.drawBeforeCreateDrawBoard
            }

            if paras.count == 3 {
                image.draw(at: CGPoint(x: pointX, y: pointY))
            } else {
                let width = try RosSentence(code: paras[3], env: self.env).evaluate()
                let height = try RosSentence(code: paras[4], env: self.env).evaluate()
                guard let width = getDouble(from: width) else {
                    throw RosParseError.paramTypeMismatch
                }
                guard let height = getDouble(from: height) else {
                    throw RosParseError.paramTypeMismatch
                }
                image.draw(in: CGRect(x: pointX, y: pointY, width: width, height: height))
            }

        case .Ros_clipToCircle:
            if paras.count < 1 { throw RosParseError.paramMissing }
            if paras.count > 1 { throw RosParseError.paramRedundant }
            let image = try RosSentence(code: paras[0], env: self.env).evaluate()

            guard let image = getUIImage(from: image) else {
                throw RosParseError.paramTypeMismatch
            }
            return image.clipToCircleImage()

        case .Ros_getImageWidth:
            if paras.count < 1 { throw RosParseError.paramMissing }
            if paras.count > 1 { throw RosParseError.paramRedundant }
            let image = try RosSentence(code: paras[0], env: self.env).evaluate()

            guard let image = getUIImage(from: image) else {
                throw RosParseError.paramTypeMismatch
            }
            return image.size.width

        case .Ros_getImageHeight:
            if paras.count < 1 { throw RosParseError.paramMissing }
            if paras.count > 1 { throw RosParseError.paramRedundant }
            let image = try RosSentence(code: paras[0], env: self.env).evaluate()

            guard let image = getUIImage(from: image) else {
                throw RosParseError.paramTypeMismatch
            }
            return image.size.height

        case .Ros_getColor:
            if paras.count < 3 { throw RosParseError.paramMissing }
            if paras.count > 4 { throw RosParseError.paramRedundant }
            let red = try RosSentence(code: paras[0], env: self.env).evaluate()
            let green = try RosSentence(code: paras[1], env: self.env).evaluate()
            let blue = try RosSentence(code: paras[2], env: self.env).evaluate()

            guard let red = getInt(from: red) else {
                throw RosParseError.paramTypeMismatch
            }
            guard red >= 0, red <= 255 else {
                throw RosParseError.paramIllegal
            }
            guard let green = getInt(from: green) else {
                throw RosParseError.paramTypeMismatch
            }
            guard green >= 0, green <= 255 else {
                throw RosParseError.paramIllegal
            }
            guard let blue = getInt(from: blue) else {
                throw RosParseError.paramTypeMismatch
            }
            guard blue >= 0, blue <= 255 else {
                throw RosParseError.paramIllegal
            }

            var alpha: Double = 1
            if paras.count == 4 {
                let theAlpha = try RosSentence(code: paras[3], env: self.env).evaluate()
                guard let theAlpha = getDouble(from: theAlpha) else {
                    throw RosParseError.paramTypeMismatch
                }
                guard theAlpha >= 0, theAlpha <= 1 else {
                    throw RosParseError.paramIllegal
                }
                alpha = theAlpha
            }
            let color = UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: alpha)
            return color

        case .Ros_createGif:
            if paras.count < 1 { throw RosParseError.paramMissing }
            if paras.count > 1 { throw RosParseError.paramRedundant }

            self.env?.setVarValue("_Ros_gifFrames", value: [UIImage]())
            try RosSentence(code: paras[0], env: self.env).evaluate()
            guard let gifFrames = self.env?.getVarValue("_Ros_gifFrames") as? [UIImage] else {
                throw RosParseError.getGifFramesFail
            }
            guard gifFrames.count > 0 else {
                throw RosParseError.noFrameInGif
            }
            self.env?.setVarValue("_Ros_finalResult", value: gifFrames)
            return gifFrames

        case .Ros_appendFrame:
            if paras.count < 1 { throw RosParseError.paramMissing }
            if paras.count > 1 { throw RosParseError.paramRedundant }
            let image = try RosSentence(code: paras[0], env: self.env).evaluate()

            guard let image = getUIImage(from: image) else {
                throw RosParseError.paramTypeMismatch
            }
            guard var gifFrames = self.env?.getVarValue("_Ros_gifFrames") as? [UIImage] else {
                throw RosParseError.appendFrameBeforeCreateGif
            }

            gifFrames.append(image)
            self.env?.setVarValue("_Ros_gifFrames", value: gifFrames)

        case .Ros_setGifFrameDuration:
            if paras.count < 1 { throw RosParseError.paramMissing }
            if paras.count > 1 { throw RosParseError.paramRedundant }
            let duration = try RosSentence(code: paras[0], env: self.env).evaluate()

            guard let duration = getInt(from: duration) else {
                throw RosParseError.paramTypeMismatch
            }
            self.env?.setVarValue("_Ros_gifFrameDuration", value: duration)


        }

        return nil
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
        }
        return nil
    }
}
