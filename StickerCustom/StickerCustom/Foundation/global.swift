//
//  global.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/15.
//

import Foundation
import UIKit

let StatusBarH = UIApplication.shared.windows.first!.windowScene!.statusBarManager!.statusBarFrame.height
var NavBarH: CGFloat {
    func getNavBarH(vc: UIViewController?) -> CGFloat? {
        if let tab = vc as? UITabBarController {
            return getNavBarH(vc: tab.viewControllers?.first)
        } else if let nav = vc as? UINavigationController {
            return nav.navigationBar.bounds.height
        } else {
            return vc?.navigationController?.navigationBar.bounds.height
        }
    }
    let rootVC = UIApplication.shared.windows.first?.rootViewController
    return getNavBarH(vc: rootVC) ?? 0
}
let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height

let TableViewCellLongPressGesMinimumPressDuration = 0.8

func presentAlert(title: String, message: String? = nil, on baseViewController: UIViewController) {
    if Thread.isMainThread {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "确定", style: .default, handler: nil)
        alert.addAction(ok)
        baseViewController.present(alert, animated: true, completion: nil)
    } else {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: "确定", style: .default, handler: nil)
            alert.addAction(ok)
            baseViewController.present(alert, animated: true, completion: nil)
        }
    }
}
