//
//  SCViewController.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/15.
//

import UIKit

class SCViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundDark
        if let navBar = navigationController?.navigationBar {
            navBar.tintColor = .white
        }
    }

}
