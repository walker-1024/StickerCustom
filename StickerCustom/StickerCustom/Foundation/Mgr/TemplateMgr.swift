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
                guard let cover = item.cover else { continue }
                guard let author = item.author else { continue }
                let template = TemplateModel(
                    templateId: templateId,
                    title: title,
                    code: code,
                    cover: cover,
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
        guard let cover = result[0].cover else { return nil }
        guard let author = result[0].author else { return nil }
        let template = TemplateModel(
            templateId: templateId,
            title: title,
            code: code,
            cover: cover,
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
    }
}
