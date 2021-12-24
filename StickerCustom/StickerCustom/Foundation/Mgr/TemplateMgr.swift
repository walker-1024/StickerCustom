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

    private init() { }

    func add(template theTemplate: TemplateModel) {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
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

    }

    // 采取标记删除的方式
    func delete(templateIds deleteTemplateIds: [String]) {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
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
