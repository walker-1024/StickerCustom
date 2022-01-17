//
//  VersionLogViewController.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2022/1/17.
//

import UIKit

class VersionLogViewController: SCViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "版本日志"
        let textView = UITextView()
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        textView.backgroundColor = .clear
        textView.textColor = .tintGreen
        textView.isEditable = false
        textView.isSelectable = false
        textView.text = """
        Ver 1.0.0 -- 2022-01-16
        一个支持生成与QQ头像有关的有趣表情包的App。
        在模板的基础上，你只需输入一个QQ号，即可使用此QQ的头像来制作一个有趣的表情包。
        你可以使用约定的特殊语言格式写出代码来制作自定义的模板，也可以下载其他用户上传的模板使用。
        """
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

}
