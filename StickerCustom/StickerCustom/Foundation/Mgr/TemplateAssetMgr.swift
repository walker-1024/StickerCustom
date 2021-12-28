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

    func getAllAssets(of templateId: UUID) -> [TemplateAssetModel]? {
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
                guard let assetId = item.assetId else { continue }
                guard let templateId = item.templateId else { continue }
                guard let name = item.name else { continue }
                guard let data = item.data else { continue }
                guard let assetType = TemplateAssetModel.AssetType(rawValue: item.assetType ?? "") else { continue }
                guard let time = item.time else { continue }
                let asset = TemplateAssetModel(
                    assetId: assetId,
                    templateId: templateId,
                    name: name,
                    data: data,
                    assetType: assetType,
                    time: time
                )
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
        item.assetId = theTemplateAsset.assetId
        item.templateId = theTemplateAsset.templateId
        item.name = theTemplateAsset.name
        item.data = theTemplateAsset.data
        item.assetType = theTemplateAsset.assetType.rawValue
        item.time = theTemplateAsset.time
        try? context.save()
    }

    func modify(templateAsset theTemplateAsset: TemplateAssetModel) {
        guard let context = context else {
            return
        }
        let fetchRequest = NSFetchRequest<TemplateAssetEntity>(entityName: "TemplateAssetEntity")
        let predicate = NSPredicate(format: "assetId == \"\(theTemplateAsset.assetId)\"")
        fetchRequest.predicate = predicate
        guard let result = try? context.fetch(fetchRequest) else { return }
        guard result.count > 0 else { return }
        result[0].name = theTemplateAsset.name
        // 目前应该只会改名字？
        //result[0].templateId = theTemplateAsset.templateId
        //result[0].data = theTemplateAsset.data
        //result[0].assetType = theTemplateAsset.assetType.rawValue
        //result[0].time = theTemplateAsset.time
        try? context.save()
    }

    func delete(templateAsset theTemplateAsset: TemplateAssetModel) {
        guard let context = context else {
            return
        }
        let fetchRequest = NSFetchRequest<TemplateAssetEntity>(entityName: "TemplateAssetEntity")
        let predicate = NSPredicate(format: "assetId == \"\(theTemplateAsset.assetId)\"")
        fetchRequest.predicate = predicate
        guard let result = try? context.fetch(fetchRequest) else { return }
        guard result.count > 0 else { return }
        context.delete(result[0])
        try? context.save()
    }
}
