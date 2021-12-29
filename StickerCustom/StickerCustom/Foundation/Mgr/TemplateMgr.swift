//
//  TemplateMgr.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/19.
//

import Foundation
import UIKit
import CoreData

let testCode = """
{新建画板，512，512，{
{画图片，丢，0，0}
{画图片，{图像圆角化，头像}，30，200，100，100}
}}
"""

class TemplateMgr {

    static let shared = TemplateMgr()

    private let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext

    private init() {
        if self.getAllTemplates()?.count == 0 {
            self.add(template: TemplateModel(title: "丢", code: testCode, cover: "icon-white".localImage?.pngData(), auther: nil))
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

    func getTemplate(withId templateId: UUID) -> TemplateModel? {
        guard let context = context else {
            return nil
        }
        let fetchRequest = NSFetchRequest<TemplateEntity>(entityName: "TemplateEntity")
        let predicate = NSPredicate(format: "templateId == \"\(templateId)\"")
        fetchRequest.predicate = predicate
        guard let result = try? context.fetch(fetchRequest) else { return nil }
        guard result.count > 0 else { return nil }
        guard let templateId = result[0].templateId else { return nil }
        guard let title = result[0].title else { return nil }
        guard let code = result[0].code else { return nil }
        let template = TemplateModel(
            templateId: templateId,
            title: title,
            code: code,
            cover: result[0].cover,
            auther: result[0].auther
        )
        return template
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
        try? context.save()
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
