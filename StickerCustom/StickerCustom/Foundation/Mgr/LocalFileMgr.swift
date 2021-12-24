//
//  LocalFileMgr.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/24.
//

import Foundation

class LocalFileManager {

    static let shared = LocalFileManager()

    private let documentsPath = NSHomeDirectory() + "/Documents/"
    private let avatarPath = NSHomeDirectory() + "/Documents/avatar.png"
    private let coverDirPath = NSHomeDirectory() + "/tmp/cover/"
    private let shareFileDirPath = NSHomeDirectory() + "/tmp/shareFile/"
    private let fileManager = FileManager()

    private init() {
        do {
            try fileManager.createDirectory(atPath: coverDirPath, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(atPath: shareFileDirPath, withIntermediateDirectories: true, attributes: nil)
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

    func isNeedUpdateAvatar(md5: String) -> Bool {
        if md5.count == 0 { return false }
        let data = try? Data(contentsOf: URL(fileURLWithPath: avatarPath))
        if data?.md5 == md5 { return false }
        return true
    }

}
