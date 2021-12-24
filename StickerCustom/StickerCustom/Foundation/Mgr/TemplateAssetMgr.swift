//
//  TemplateAssetMgr.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/24.
//

import Foundation
import UIKit
import CoreData

class TemplateAssetMgr {

    static let shared = TemplateAssetMgr()

    private let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext

    private init() { }

    func getAllAssets(of templateId: String) -> [TemplateAssetModel]? {
        guard let context = context else {
            return nil
        }

        var files: [TemplateAssetModel] = []
        do {
            let fetchRequest = NSFetchRequest<TemplateAssetEntity>(entityName:"TemplateAssetEntity")
            let predicate = NSPredicate(format: "templateId == \"\(templateId)\"")
            fetchRequest.predicate = predicate
            let result = try context.fetch(fetchRequest)
            for item in result {
                guard let templateId = item.templateId else { continue }
                guard let name = item.name else { continue }
                guard let data = item.data else { continue }
                guard let assetType = TemplateAssetModel.AssetType(rawValue: item.assetType ?? "") else { continue }
                guard let time = item.time else { continue }
                let asset = TemplateAssetModel(templateId: templateId, name: name, data: data, assetType: assetType, time: time)
                files.append(asset)
            }
        } catch {
            return nil
        }

        return files
    }

    func add(templateAsset theTemplateAsset: TemplateAssetModel) {
        guard let context = context else {
            return
        }
        guard let item = NSEntityDescription.insertNewObject(forEntityName: "TemplateAssetEntity", into: context) as? TemplateAssetEntity else {
            return
        }
        item.templateId = theTemplateAsset.templateId
        item.name = theTemplateAsset.name
        item.data = theTemplateAsset.data
        item.assetType = theTemplateAsset.assetType.rawValue
        item.time = theTemplateAsset.time
        try? context.save()
    }

    func modify(templateAsset theTemplateAsset: TemplateAssetModel) {

    }

    func delete(templateAsset theTemplateAsset: TemplateAssetModel) {
        guard let context = context else {
            return
        }
        let fetchRequest = NSFetchRequest<TemplateAssetEntity>(entityName: "TemplateAssetEntity")
        let predicate = NSPredicate(format: "templateId == \"\(theTemplateAsset.templateId)\" && name == \"\(theTemplateAsset.name)\" && assetType == \"\(theTemplateAsset.assetType.rawValue)\" && time == \"\(theTemplateAsset.time)\"")
        fetchRequest.predicate = predicate
        guard let result = try? context.fetch(fetchRequest) else { return }
        guard result.count > 0 else { return }
        context.delete(result[0])
        try? context.save()
    }
}
