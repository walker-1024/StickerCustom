//
//  TemplateMgr.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/19.
//

import Foundation
import UIKit
import CoreData

class TemplateMgr {

    static let shared = TemplateMgr()

    private let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext

    private init() { }

    func addBuiltInTemplatesIfNeeded() {
        guard let context = context else {
            return
        }
        let fetchRequest = NSFetchRequest<TemplateEntity>(entityName: "TemplateEntity")
        guard let result = try? context.fetch(fetchRequest) else { return }
        if result.count == 0 {
            DispatchQueue.global().async {
                for item in [
                    "30BCEFAD-393B-4A70-9BCA-DA90F37F9952",
                    "3484FFCA-9DF0-42E9-95D8-EAE1FA8B761F",
                    "3D0F7574-A88D-43C2-AC70-1566C88C3681",
                    "42DD8909-5E50-45D8-8786-110D159A22DA",
                    "659A231A-10CF-4927-AB85-0866D0E0A99C",
                    "72A01443-458F-4B59-9A0B-62D8D1C28F8F",
                    "8CCAFD73-D198-4D83-A9BA-1505C7059730",
                    "8D817BCB-C0C6-4406-BD6C-B3338DD8136E",
                    "8E640886-2637-49BC-8C8E-FD96DCC3194D",
                    "B1716698-80D4-48DB-B1C6-84FCC1611569",
                    "D74C8598-46C9-4D3E-B5F1-E0C9A683CB76",
                    "E582BAA9-37E8-4CE9-882B-FDD4949DF2B2",
                    "E6922DC4-6C37-4EBC-A203-67BEC27BC58E",
                    "FC85B389-1674-4CA5-AAB2-E9148CD7DA45",
                    "FE806C52-056E-45F4-B7E0-2CC604F4A4F9",
                ] {
                    guard let templateId = UUID(uuidString: item) else { continue }
                    guard let path = Bundle.main.path(forResource: item, ofType: "zip") else { continue }
                    LocalFileManager.shared.downloadTemplate(withId: templateId, url: URL(fileURLWithPath: path), completion: nil)
                }
                NotificationCenter.default.post(name: .needRefreshTemplateList, object: self)
            }
        }
    }

    func getAllTemplates() -> [TemplateModel]? {
        guard let context = context else {
            return nil
        }

        var models: [TemplateModel] = []
        do {
            let fetchRequest = NSFetchRequest<TemplateEntity>(entityName: "TemplateEntity")
            let predicate = NSPredicate(format: "isDelete == false")
            fetchRequest.predicate = predicate
            let result = try context.fetch(fetchRequest)
            for item in result {
                guard let templateId = item.templateId else { continue }
                guard let title = item.title else { continue }
                guard let code = item.code else { continue }
                guard let author = item.author else { continue }
                let template = TemplateModel(
                    templateId: templateId,
                    title: title,
                    code: code,
                    cover: item.cover,
                    author: author
                )
                models.append(template)
            }
        } catch {
            return nil
        }

        return models
    }

    func getTemplate(withId templateId: UUID) -> TemplateModel? {
        guard let context = context else {
            return nil
        }
        let fetchRequest = NSFetchRequest<TemplateEntity>(entityName: "TemplateEntity")
        let predicate = NSPredicate(format: "templateId == \"\(templateId)\" && isDelete == false")
        fetchRequest.predicate = predicate
        guard let result = try? context.fetch(fetchRequest) else { return nil }
        guard result.count > 0 else { return nil }
        guard let templateId = result[0].templateId else { return nil }
        guard let title = result[0].title else { return nil }
        guard let code = result[0].code else { return nil }
        guard let author = result[0].author else { return nil }
        let template = TemplateModel(
            templateId: templateId,
            title: title,
            code: code,
            cover: result[0].cover,
            author: author
        )
        return template
    }

    @discardableResult
    func add(template theTemplate: TemplateModel) -> Bool {
        guard let context = context else {
            return false
        }
        // 判断此模板是否已存在
        let fetchRequest = NSFetchRequest<TemplateEntity>(entityName: "TemplateEntity")
        let predicate = NSPredicate(format: "templateId == \"\(theTemplate.templateId)\" && isDelete == false")
        fetchRequest.predicate = predicate
        guard let result = try? context.fetch(fetchRequest) else { return false }
        guard result.count == 0 else { return false }

        guard let item = NSEntityDescription.insertNewObject(forEntityName: "TemplateEntity", into: context) as? TemplateEntity else {
            return false
        }
        item.templateId = theTemplate.templateId
        item.title = theTemplate.title
        item.cover = theTemplate.cover
        item.code = theTemplate.code
        item.author = theTemplate.author
        item.isDelete = false
        try? context.save()
        return true
    }

    func modify(template theTemplate: TemplateModel) {
        guard let context = context else {
            return
        }
        let fetchRequest = NSFetchRequest<TemplateEntity>(entityName: "TemplateEntity")
        let predicate = NSPredicate(format: "templateId == \"\(theTemplate.templateId)\" && isDelete == false")
        fetchRequest.predicate = predicate
        guard let result = try? context.fetch(fetchRequest) else { return }
        guard result.count > 0 else { return }
        result[0].title = theTemplate.title
        result[0].cover = theTemplate.cover
        result[0].code = theTemplate.code
        result[0].author = theTemplate.author
        try? context.save()
    }

    // 采取标记删除的方式
    func delete(templateIds deleteTemplateIds: [UUID]) {
        guard let context = context else {
            return
        }
        for deleteTemplateId in deleteTemplateIds {
            let fetchRequest = NSFetchRequest<TemplateEntity>(entityName: "TemplateEntity")
            let predicate = NSPredicate(format: "templateId == \"\(deleteTemplateId)\" && isDelete == false")
            fetchRequest.predicate = predicate
            guard let result = try? context.fetch(fetchRequest) else { continue }
            guard result.count > 0 else { continue }
            result[0].isDelete = true
        }
        try? context.save()

        // 删除它所包含的素材
        for deleteTemplateId in deleteTemplateIds {
            TemplateAssetMgr.shared.deleteAllAssets(of: deleteTemplateId)
        }
    }
}
