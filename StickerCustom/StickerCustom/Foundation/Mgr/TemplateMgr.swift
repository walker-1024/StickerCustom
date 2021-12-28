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
                let template = TemplateModel(
                    templateId: templateId,
                    title: title,
                    code: code,
                    cover: item.cover,
                    auther: item.auther
                )
                models.append(template)
            }
        } catch {
            return nil
        }

        return models
    }

    func add(template theTemplate: TemplateModel) {
        guard let context = context else {
            return
        }
        guard let item = NSEntityDescription.insertNewObject(forEntityName: "TemplateEntity", into: context) as? TemplateEntity else {
            return
        }
        item.templateId = theTemplate.templateId
        item.title = theTemplate.title
        item.cover = theTemplate.cover
        item.code = theTemplate.code
        item.auther = theTemplate.auther
        item.isDelete = false
        try? context.save()
    }

    func modify(template theTemplate: TemplateModel) {
        guard let context = context else {
            return
        }
        let fetchRequest = NSFetchRequest<TemplateEntity>(entityName: "TemplateEntity")
        let predicate = NSPredicate(format: "templateId == \"\(theTemplate.templateId)\"")
        fetchRequest.predicate = predicate
        guard let result = try? context.fetch(fetchRequest) else { return }
        guard result.count > 0 else { return }
        result[0].title = theTemplate.title
        result[0].cover = theTemplate.cover
        result[0].code = theTemplate.code
        result[0].auther = theTemplate.auther
    }

    // 采取标记删除的方式
    func delete(templateIds deleteTemplateIds: [UUID]) {
        guard let context = context else {
            return
        }
        let fetchRequest = NSFetchRequest<TemplateEntity>(entityName: "TemplateEntity")
        guard let result = try? context.fetch(fetchRequest) else { return }
        for item in result {
            guard let templateId = item.templateId else { continue }
            if deleteTemplateIds.contains(templateId) {
                item.isDelete = true
            }
        }
        try? context.save()
    }
}
