//
//  UserViewController.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/16.
//

import UIKit

class UserViewController: SCViewController {

    private let profileView = UIView()
    private let avatarImageView = UIImageView()
    private let usernameLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfile()

        // 临时写这里
        let logoutButton = UIButton()
        view.addSubview(logoutButton)
        logoutButton.snp.makeConstraints { make in
            make.bottom.equalTo(-100)
            make.height.equalTo(50)
            make.width.equalTo(200)
            make.centerX.equalToSuperview()
        }
        logoutButton.setTitle("退出登录", for: .normal)
        logoutButton.setTitleColor(.tintGreen, for: .normal)
        logoutButton.addTarget(self, action: #selector(clickLogout), for: .touchUpInside)
        logoutButton.layer.cornerRadius = 6
        logoutButton.layer.masksToBounds = true
        logoutButton.layer.borderWidth = 2
        logoutButton.layer.borderColor = UIColor.tintGreen.cgColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)

    }

    private func setupProfile() {
        view.addSubview(profileView)
        profileView.snp.makeConstraints { make in
            make.top.equalTo(StatusBarH)
            make.height.equalTo(125)
            make.width.equalTo(350)
            make.centerX.equalToSuperview()
        }
        let ges = UITapGestureRecognizer(target: self, action: #selector(clickLogin))
        profileView.addGestureRecognizer(ges)

        profileView.addSubview(avatarImageView)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.snp.makeConstraints { make in
            make.leading.equalTo(10)
            make.width.height.equalTo(80)
            make.centerY.equalToSuperview()
        }
        avatarImageView.image = "icon-default-avatar".localImage
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 40
        avatarImageView.layer.masksToBounds = true
        avatarImageView.isUserInteractionEnabled = true
        let gest = UITapGestureRecognizer(target: self, action: #selector(clickAvatar))
        avatarImageView.addGestureRecognizer(gest)

        profileView.addSubview(usernameLabel)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(20)
            make.bottom.equalTo(profileView.snp.centerY).offset(-5)
            make.height.equalTo(30)
            make.trailing.equalTo(-10)
        }
        usernameLabel.text = "未登录"
        usernameLabel.textAlignment = .left
        usernameLabel.textColor = .tintGreen
        usernameLabel.font = UIFont.systemFont(ofSize: 20)

        let tipLabel = UILabel()
        profileView.addSubview(tipLabel)
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        tipLabel.snp.makeConstraints { make in
            make.leading.equalTo(usernameLabel)
            make.trailing.equalTo(usernameLabel)
            make.top.equalTo(profileView.snp.centerY).offset(5)
            make.height.equalTo(20)
        }
        tipLabel.text = "点击头像修改资料"
        tipLabel.textAlignment = .left
        tipLabel.textColor = .tintGreen
        tipLabel.font = UIFont.systemFont(ofSize: 12)
    }

    @objc private func clickAvatar() {
        if UserConfigMgr.shared.getValue(of: .token) == nil {
            clickLogin()
            return
        }
//        let vc = ModifyProfileViewController()
//        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func clickLogin() {
        if UserConfigMgr.shared.getValue(of: .token) == nil {
            let vc = LoginViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc private func clickLogout() {
        guard let _ = UserConfigMgr.shared.getValue(of: .token) else { return }
        let alert = UIAlertController(title: "退出登录", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "确定", style: .default, handler: { _ in
            self.usernameLabel.text = "未登录"
            self.avatarImageView.image = "icon-default-avatar".localImage
            UserConfigMgr.shared.logout()
        })
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

}
