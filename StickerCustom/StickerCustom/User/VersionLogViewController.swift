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
        Ver 1.1.0
        1. 代码执行的报错信息人性化处理。
        2. 「设置帧延迟」函数的参数的类型改为整数，单位改为毫秒。
        3. 编辑代码时，键盘不会再挡代码。
        4. 修复删除模板后，它所包含的素材未被删除的问题。
        5. 开放登录。
        6. 广场加载模板列表时，封面异步加载。
        Ver 1.0.0 -- 2022-01-16
        1. 一个支持生成与QQ头像有关的有趣表情包的App。
        2. 在模板的基础上，你只需输入一个QQ号，即可使用此QQ的头像来制作一个有趣的表情包。
        3. 你可以使用约定的特殊语言格式写出代码来制作自定义的模板，也可以下载其他用户上传的模板使用。
        """
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

}
