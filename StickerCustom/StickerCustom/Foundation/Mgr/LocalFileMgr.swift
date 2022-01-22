//
//  LocalFileMgr.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/24.
//

import Foundation
import SSZipArchive

class LocalFileManager {

    static let shared = LocalFileManager()

    private let documentsPath = NSHomeDirectory() + "/Documents/"
    private let avatarPath = NSHomeDirectory() + "/Documents/avatar.png"
    private let coverDirPath = NSHomeDirectory() + "/tmp/cover/"
    private let shareFileDirPath = NSHomeDirectory() + "/tmp/shareFile/"
    private let templateDirPath = NSHomeDirectory() + "/tmp/template/"
    private let templateZipDirPath = NSHomeDirectory() + "/tmp/templateZip/"
    private let tempImageDirPath = NSHomeDirectory() + "/tmp/tempImage/"
    private let fileManager = FileManager()

    private init() {
        do {
            try fileManager.createDirectory(atPath: coverDirPath, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(atPath: shareFileDirPath, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(atPath: templateDirPath, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(atPath: templateZipDirPath, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(atPath: tempImageDirPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
        }
    }

    func saveAvatar(data: Data) {
        fileManager.createFile(atPath: avatarPath, contents: data, attributes: nil)
    }

    func getAvatar() -> Data? {
        let data = try? Data(contentsOf: URL(fileURLWithPath: avatarPath))
        return data
    }

    func removeAvatar() {
        try? fileManager.removeItem(atPath: avatarPath)
    }

    func isNeedUpdateAvatar(md5: String) -> Bool {
        if md5.count == 0 { return false }
        let data = try? Data(contentsOf: URL(fileURLWithPath: avatarPath))
        if data?.md5 == md5 { return false }
        return true
    }

    func saveCover(data: Data, name: String) {
        let path = coverDirPath + name + ".pic"
        fileManager.createFile(atPath: path, contents: data, attributes: nil)
    }

    func getCover(name: String) -> Data? {
        let path = coverDirPath + name + ".pic"
        let data = try? Data(contentsOf: URL(fileURLWithPath: path))
        return data
    }

    func getTempPath(suffix: String) -> String {
        let now = Date().timeIntervalSince1970
        return tempImageDirPath + "\(now)." + suffix
    }

    func archiveTemplate(withId templateId: UUID, completion: ((Data?, String?) -> Void)?) {
        guard let template = TemplateMgr.shared.getTemplate(withId: templateId) else {
            completion?(nil, "模板不存在")
            return
        }
        guard let assets = TemplateAssetMgr.shared.getAllAssets(of: templateId) else {
            completion?(nil, "模板素材不存在")
            return
        }
        guard let coverData = template.cover else {
            completion?(nil, "请先设置模板封面")
            return
        }

        let basePath = templateDirPath + templateId.uuidString + "/"
        try? fileManager.removeItem(atPath: basePath)
        try? fileManager.createDirectory(atPath: basePath, withIntermediateDirectories: true, attributes: nil)
        let assetsPath = basePath + "assets/"
        try? fileManager.createDirectory(atPath: assetsPath, withIntermediateDirectories: true, attributes: nil)

        var assetList: [[String: Any]] = []
        for asset in assets {
            fileManager.createFile(atPath: assetsPath + asset.getFileName(), contents: asset.data, attributes: nil)
            let dic: [String: Any] = [
                "assetId": asset.assetId.uuidString,
                "templateId": asset.templateId.uuidString,
                "name": asset.name,
                "assetType": asset.assetType.rawValue,
                "time": asset.time
            ]
            assetList.append(dic)
        }

        fileManager.createFile(atPath: basePath + "cover.png", contents: coverData, attributes: nil)
        let coverMd5 = coverData.md5
        let dic: [String : Any] = [
            "templateId": template.templateId.uuidString,
            "title": template.title,
            "code": template.code,
            "author": template.author,
            "coverMd5": coverMd5,
            "assetList": assetList
        ]

        // 注意必须先用 isValidJSONObject 判断是否能够 JSON 序列化，如果不能，那么到时候即使用 try? 也会 crash
        guard JSONSerialization.isValidJSONObject(dic) else {
            completion?(nil, "失败")
            return
        }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted) else {
            completion?(nil, "失败")
            return
        }
        fileManager.createFile(atPath: basePath + "Contents.json", contents: jsonData, attributes: nil)

        let zipPath = templateZipDirPath + templateId.uuidString + ".zip"
        guard SSZipArchive.createZipFile(atPath: zipPath, withContentsOfDirectory: basePath, keepParentDirectory: true) else {
            completion?(nil, "压缩文件失败")
            return
        }
        guard let result = try? Data(contentsOf: URL(fileURLWithPath: zipPath)) else {
            completion?(nil, "压缩文件失败")
            return
        }

        completion?(result, nil)
    }

    func downloadTemplate(withId templateId: UUID, url: URL, completion: ((TemplateModel?, String?) -> Void)?) {
        if TemplateMgr.shared.getTemplate(withId: templateId) != nil {
            completion?(nil, "模板已存在")
            return
        }
        guard let templateData = try? Data(contentsOf: url) else {
            completion?(nil, "下载文件失败")
            return
        }
        let zipPath = templateZipDirPath + templateId.uuidString + ".zip"
        fileManager.createFile(atPath: zipPath, contents: templateData, attributes: nil)
        guard SSZipArchive.unzipFile(atPath: zipPath, toDestination: templateDirPath) else {
            completion?(nil, "解压文件失败")
            return
        }
        let contentDirPath = templateDirPath + templateId.uuidString + "/"
        guard let allContent = try? fileManager.contentsOfDirectory(atPath: contentDirPath) else {
            completion?(nil, "获取文件内容失败")
            return
        }

        guard allContent.contains("Contents.json"), allContent.contains("cover.png"), allContent.contains("assets") else {
            completion?(nil, "文件数据缺失")
            return
        }

        guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: contentDirPath + "Contents.json")) else {
            completion?(nil, "读文件失败")
            return
        }

        guard let dic = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: Any] else {
            completion?(nil, "文件信息错误")
            return
        }
        guard let templateId = UUID(uuidString: dic["templateId"] as? String ?? ""),
        let title = dic["title"] as? String,
        let code = dic["code"] as? String,
        let author = dic["author"] as? String,
        let coverMd5 = dic["coverMd5"] as? String,
        let assetList = dic["assetList"] as? [[String: Any]]
        else {
            completion?(nil, "文件信息错误")
            return
        }

        guard let coverData = try? Data(contentsOf: URL(fileURLWithPath: contentDirPath + "cover.png")) else {
            completion?(nil, "读文件失败")
            return
        }
        guard coverData.md5 == coverMd5 else {
            completion?(nil, "文件校验失败")
            return
        }

        for assetDic in assetList {
            guard let assetId = UUID(uuidString: assetDic["assetId"] as? String ?? ""),
            templateId.uuidString == assetDic["templateId"] as? String,
            let name = assetDic["name"] as? String,
            let assetType = TemplateAssetModel.AssetType(rawValue: assetDic["assetType"] as? String ?? ""),
            let time = assetDic["time"] as? String
            else {
                completion?(nil, "文件信息错误")
                return
            }
            guard let assetData = try? Data(contentsOf: URL(fileURLWithPath: contentDirPath + "assets/" + TemplateAssetModel.getFileName(assetId: assetId, assetType: assetType))) else {
                completion?(nil, "读文件失败")
                return
            }
            let asset = TemplateAssetModel(
                assetId: assetId,
                templateId: templateId,
                name: name,
                data: assetData,
                assetType: assetType,
                time: time
            )
            TemplateAssetMgr.shared.add(templateAsset: asset)
        }

        let template = TemplateModel(
            templateId: templateId,
            title: title,
            code: code,
            cover: coverData,
            author: author
        )
        TemplateMgr.shared.add(template: template)

        completion?(template, nil)
    }

}
