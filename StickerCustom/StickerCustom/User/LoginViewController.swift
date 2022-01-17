//
//  LoginViewController.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2022/1/17.
//

import UIKit

class LoginViewController: SCViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "登录"
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)

    }

    private func setup() {
        let iconView = UIImageView()
        view.addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(120)
            make.top.equalTo(StatusBarH + NavBarH + 50)
        }
        iconView.image = "icon".localImage
        iconView.layer.cornerRadius = 8
        iconView.layer.masksToBounds = true

        let qqLoginButton = UIButton()
        view.addSubview(qqLoginButton)
        qqLoginButton.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(50)
            make.height.equalTo(50)
            make.width.equalTo(200)
            make.centerX.equalToSuperview()
        }
        qqLoginButton.setTitle("QQ登录", for: .normal)
        qqLoginButton.setTitleColor(.tintGreen, for: .normal)
        qqLoginButton.addTarget(self, action: #selector(clickQQLogin), for: .touchUpInside)
        qqLoginButton.layer.cornerRadius = 6
        qqLoginButton.layer.masksToBounds = true
        qqLoginButton.layer.borderWidth = 2
        qqLoginButton.layer.borderColor = UIColor.tintGreen.cgColor
    }

    @objc private func clickQQLogin() {
        if !TencentOpenAPITool.shared.login() {
            presentAlert(title: "登录失败", message: "未知错误", on: self)
        }
    }

}
