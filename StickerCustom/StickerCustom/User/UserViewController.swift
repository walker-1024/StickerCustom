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
    private let uidLabel = UILabel()
    private let logoutButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfile()

        // 临时写这里
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
        logoutButton.isHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(didGetQQUserInfo(notification:)), name: .getQQUserInfoSuccess, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        guard let _ = UserConfigMgr.shared.getValue(of: .token) as? String else { return }
        logoutButton.isHidden = false
        if let username = UserConfigMgr.shared.getValue(of: .username) as? String {
            usernameLabel.text = username
        } else {
            usernameLabel.text = "未设置昵称"
        }
        if let imageData = LocalFileManager.shared.getAvatar() {
            avatarImageView.image = UIImage(data: imageData)
        } else {
            avatarImageView.image = "icon-default-avatar".localImage
        }
        if let UID = UserConfigMgr.shared.getValue(of: .UID) as? String {
            uidLabel.isHidden = false
            uidLabel.text = "UID:  \(UID)"
        }
        refreshProfile()
        // TODO: 考虑Apple或QQ的登录态失效的情况
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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

        profileView.addSubview(uidLabel)
        uidLabel.translatesAutoresizingMaskIntoConstraints = false
        uidLabel.snp.makeConstraints { make in
            make.leading.equalTo(usernameLabel)
            make.trailing.equalTo(usernameLabel)
            make.top.equalTo(profileView.snp.centerY).offset(5)
            make.height.equalTo(20)
        }
//        uidLabel.text = "点击头像修改资料"
        uidLabel.textAlignment = .left
        uidLabel.textColor = .tintGreen
        uidLabel.font = UIFont.systemFont(ofSize: 15)
        uidLabel.isHidden = true
    }

    private func refreshProfile() {
        let config = WebAPIConfig(subspec: "user", function: "info")
        NetworkMgr.shared.request(config: config).responseModel { (result: NetworkResult<BackDataWrapper<UserInfoBackData>>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    if res.code == 0, let backData = res.data {
                        print(backData.name, backData.point, backData.identity, backData.UID)
                        self.uidLabel.isHidden = false
                        self.uidLabel.text = "UID:  \(backData.UID)"
                        UserConfigMgr.shared.saveValue(backData.UID, to: .UID)
                    } else {
                        // 后端有个小bug，先包一下
//                        presentAlert(title: res.msg, on: self)
//                        self.innerLogout()
                    }
                case .failure(_):
                    break
                }
            }
        }
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
            self.innerLogout()
        })
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    private func innerLogout() {
        usernameLabel.text = "未登录"
        uidLabel.isHidden = true
        avatarImageView.image = "icon-default-avatar".localImage
        UserConfigMgr.shared.logout()
        LocalFileManager.shared.removeAvatar()
        logoutButton.isHidden = true
    }

    @objc private func didGetQQUserInfo(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        DispatchQueue.main.async {
            if let name = userInfo["name"] as? String {
                self.usernameLabel.text = name
                UserConfigMgr.shared.saveValue(name, to: .username)
            }
            DispatchQueue.global().async {
                guard let avatarUrl = userInfo["avatarUrl"] as? URL else { return }
                guard let avatarData = try? Data(contentsOf: avatarUrl) else { return }
                guard LocalFileManager.shared.isNeedUpdateAvatar(md5: avatarData.md5) else { return }
                LocalFileManager.shared.saveAvatar(data: avatarData)
                DispatchQueue.main.async {
                    self.avatarImageView.image = UIImage(data: avatarData)
                }
            }
        }
    }
}

fileprivate struct UserInfoBackData: Codable {
    var UID: String
    var name: String
    var point: Int
    var identity: Int
}
