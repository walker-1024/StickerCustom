//
//  RosParseError.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2022/1/19.
//

import Foundation

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
    /// 参数数值不合法
    ///
    /// 比如取颜色函数的前三个参数要求是 0 ~ 255，而用户传入了此范围之外的数字
    case paramIllegal
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
    /// 「画图片」函数没有写在「新建画板」函数内
    ///
    /// 直接原因是在「画图片」时获取 context 失败
    case drawBeforeCreateDrawBoard
    /// 「创建动图」时最终没能获取到帧集合
    ///
    /// 可能是子语句把「创建动图」写入环境的那个数组变量搞坏了或者搞没了，一般情况不会出现此问题
    case getGifFramesFail
    /// 「添加帧」函数没有放在「创建动图」函数内
    ///
    /// 直接原因是在「添加帧」时获取 gifFrames 失败
    case appendFrameBeforeCreateGif
    /// 未获取到结果
    ///
    /// 用户没有进行任何「新建画板」或「创建动图」的操作
    case noResult
    /// 「创建动图」里没有添加任何帧
    ///
    ///
    case noFrameInGif
    /// 使用 UIImage 数组创建 gif 失败了
    ///
    /// 一般不会出现此问题
    case createGifFail
    /// 变量不存在
    ///
    /// 用户使用 {xxx} 的方式去获取一个不存在的变量的值
    case varNameNotExist

    var message: String {
        switch self {
        case .fetchQQAvatarFail:
            return "获取QQ头像失败"
        case .wrongSentence:
            return "左右大括号数量不匹配"
        case .functionNameNull:
            return "函数名为空"
        case .funcNameNotExist:
            return "函数不存在"
        case .paramTypeMismatch:
            return "参数类型不匹配"
        case .paramIllegal:
            return "参数数值不合法"
        case .paramMissing:
            return "参数缺失"
        case .paramRedundant:
            return "参数多余"
        case .paramNumMismatch:
            return "参数数量不匹配"
        case .drawBeforeCreateDrawBoard:
            return "「画图片」函数没有写在「新建画板」函数内"
        case .getGifFramesFail:
            return "「创建动图」取帧失败"
        case .appendFrameBeforeCreateGif:
            return "「添加帧」函数没有放在「创建动图」函数内"
        case .noResult:
            return "未进行任何画图或创建动图操作"
        case .noFrameInGif:
            return "「创建动图」里没有添加任何帧"
        case .createGifFail:
            return "「创建动图」失败"
        case .varNameNotExist:
            return "变量不存在"
        }
    }
}
