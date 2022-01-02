//
//  SCViewController.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/15.
//

import UIKit
import SnapKit

class SCViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundDark
        if let navBar = navigationController?.navigationBar {
            navBar.tintColor = .white

            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.backgroundColor = UIColor.backgroundDark
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 20)]
            navBar.scrollEdgeAppearance = navBarAppearance
            navBar.standardAppearance = navBarAppearance
        }
    }

    func getAppPrompt() -> UIView {
        let box = UIView()
        let iconView = UIImageView(image: "icon-white".localImage)
        box.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        let appName = UILabel()
        box.addSubview(appName)
        appName.snp.makeConstraints { (make) in
            make.leading.equalTo(iconView.snp.trailing).offset(5)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(iconView.snp.centerY)
        }
        appName.text = "M e m e e t"
        appName.textColor = .white
        appName.backgroundColor = .clear
        appName.font = UIFont.systemFont(ofSize: 23)
        return box
    }

}
