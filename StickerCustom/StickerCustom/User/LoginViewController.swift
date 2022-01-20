//
//  LoginViewController.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2022/1/17.
//

import UIKit
import AuthenticationServices

class LoginViewController: SCViewController {

    private let uidTextField = UITextField()
    private let pwdTextField = UITextField()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "登录"
        setup()
        // 两种UI，第一种先留着代码
        //setupThirdLoginButton_1()
        setupThirdLoginButton_2()
        NotificationCenter.default.addObserver(self, selector: #selector(didQQLogin(notification:)), name: .qqLoginSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didAppleLogin(notification:)), name: .appleLoginSuccess, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        uidTextField.resignFirstResponder()
        pwdTextField.resignFirstResponder()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setup() {
        let TextFieldWidth: CGFloat = 280
        let TextFieldHeight: CGFloat = 50

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

        view.addSubview(uidTextField)
        uidTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(TextFieldWidth)
            make.top.equalTo(iconView.snp.bottom).offset(70)
            make.height.equalTo(TextFieldHeight)
        }
        uidTextField.backgroundColor = .clear
        uidTextField.textColor = .tintGreen
        uidTextField.textAlignment = .center
        uidTextField.font = UIFont.systemFont(ofSize: 18)
        uidTextField.keyboardType = .default
        uidTextField.returnKeyType = .done
        uidTextField.autocorrectionType = .no
        uidTextField.autocapitalizationType = .none
        uidTextField.delegate = self
        uidTextField.layer.cornerRadius = 8
        uidTextField.layer.masksToBounds = true
        uidTextField.layer.borderWidth = 2
        uidTextField.layer.borderColor = UIColor.tintGreen.cgColor

        let uidLabel = UILabel()
        view.addSubview(uidLabel)
        uidLabel.snp.makeConstraints { make in
            make.leading.equalTo(uidTextField).offset(5)
            make.bottom.equalTo(uidTextField.snp.top)
            make.height.equalTo(30)
        }
        uidLabel.text = "UID"
        uidLabel.textColor = .tintGreen

        view.addSubview(pwdTextField)
        pwdTextField.snp.makeConstraints { make in
            make.top.equalTo(uidTextField.snp.bottom).offset(40)
            make.leading.trailing.equalTo(uidTextField)
            make.height.equalTo(uidTextField)
        }
        pwdTextField.backgroundColor = .clear
        pwdTextField.textColor = .tintGreen
        pwdTextField.textAlignment = .center
        pwdTextField.font = UIFont.systemFont(ofSize: 18)
        pwdTextField.keyboardType = .default
        pwdTextField.returnKeyType = .done
        pwdTextField.autocorrectionType = .no
        pwdTextField.autocapitalizationType = .none
        pwdTextField.isSecureTextEntry = true
        pwdTextField.delegate = self
        pwdTextField.layer.cornerRadius = 8
        pwdTextField.layer.masksToBounds = true
        pwdTextField.layer.borderWidth = 2
        pwdTextField.layer.borderColor = UIColor.tintGreen.cgColor

        let pwdLabel = UILabel()
        view.addSubview(pwdLabel)
        pwdLabel.snp.makeConstraints { make in
            make.leading.equalTo(pwdTextField).offset(5)
            make.bottom.equalTo(pwdTextField.snp.top)
            make.height.equalTo(uidLabel)
        }
        pwdLabel.text = "密码"
        pwdLabel.textColor = .tintGreen

        let loginButton = UIButton()
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(pwdTextField.snp.bottom).offset(40)
            make.height.equalTo(uidTextField)
            make.leading.trailing.equalTo(uidTextField)
            make.centerX.equalToSuperview()
        }
        loginButton.setTitle("登录", for: .normal)
        loginButton.setTitleColor(.tintGreen, for: .normal)
        loginButton.addTarget(self, action: #selector(clickUIDLogin(button:)), for: .touchUpInside)
        loginButton.layer.cornerRadius = 6
        loginButton.layer.masksToBounds = true
        loginButton.layer.borderWidth = 2
        loginButton.layer.borderColor = UIColor.tintGreen.cgColor
    }

    private func setupThirdLoginButton_1() {
        let appleLoginButton = ASAuthorizationAppleIDButton(type: .default, style: .white)
        view.addSubview(appleLoginButton)
        appleLoginButton.snp.makeConstraints { make in
            make.bottom.equalTo(-60)
            make.centerX.equalToSuperview()
            make.width.equalTo(280)
            make.height.equalTo(280 * 30 / 130)
        }
        appleLoginButton.addTarget(self, action: #selector(clickAppleLogin), for: .touchUpInside)

        let qqLoginButton = UIButton()
        view.addSubview(qqLoginButton)
        qqLoginButton.snp.makeConstraints { make in
            make.bottom.equalTo(appleLoginButton.snp.top).offset(-30)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(appleLoginButton)
        }
        qqLoginButton.backgroundColor = .white
        qqLoginButton.addTarget(self, action: #selector(clickQQLogin), for: .touchUpInside)
        qqLoginButton.layer.cornerRadius = 8
        qqLoginButton.layer.masksToBounds = true

        let qqIcon = UIImageView()
        qqLoginButton.addSubview(qqIcon)
        qqIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalTo(qqLoginButton.snp.height)
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
        }
        qqIcon.image = "icon-qq".localImage
        qqIcon.contentMode = .scaleAspectFit

        let qqLabel = UILabel()
        qqLoginButton.addSubview(qqLabel)
        qqLabel.snp.makeConstraints { make in
            make.leading.equalTo(qqIcon.snp.trailing)
            make.trailing.top.bottom.equalToSuperview()
        }
        qqLabel.backgroundColor = UIColor(red: 26, green: 86, blue: 209)
        qqLabel.text = "QQ 快速登录"
        qqLabel.textColor = .white
        qqLabel.textAlignment = .center
        qqLabel.font = UIFont.systemFont(ofSize: 23)
    }

    private func setupThirdLoginButton_2() {
        let buttonDiameter: CGFloat = 60

        let qqLoginButton = UIButton()
        view.addSubview(qqLoginButton)
        qqLoginButton.snp.makeConstraints { make in
            make.bottom.equalTo(-70)
            make.trailing.equalTo(view.snp.centerX).offset(-30)
            make.width.height.equalTo(buttonDiameter)
        }
        qqLoginButton.backgroundColor = UIColor(red: 26, green: 86, blue: 209)
        qqLoginButton.setImage("icon-qq-white".localImage, for: .normal)
        qqLoginButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        qqLoginButton.addTarget(self, action: #selector(clickQQLogin), for: .touchUpInside)
        qqLoginButton.layer.cornerRadius = buttonDiameter / 2
        qqLoginButton.layer.masksToBounds = true
        qqLoginButton.layer.borderWidth = 1
        qqLoginButton.layer.borderColor = UIColor.white.cgColor

        let appleLoginButton = UIButton()
        view.addSubview(appleLoginButton)
        appleLoginButton.snp.makeConstraints { make in
            make.bottom.equalTo(qqLoginButton)
            make.leading.equalTo(view.snp.centerX).offset(30)
            make.width.height.equalTo(buttonDiameter)
        }
        appleLoginButton.backgroundColor = .black
        appleLoginButton.setImage("icon-apple-white".localImage, for: .normal)
        appleLoginButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        appleLoginButton.addTarget(self, action: #selector(clickAppleLogin), for: .touchUpInside)
        appleLoginButton.layer.cornerRadius = buttonDiameter / 2
        appleLoginButton.layer.masksToBounds = true
        appleLoginButton.layer.borderWidth = 1
        appleLoginButton.layer.borderColor = UIColor.white.cgColor

        let tipLabel = UILabel()
        view.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(qqLoginButton.snp.top).offset(-10)
            make.height.equalTo(30)
        }
        tipLabel.text = "其它登录方式"
        tipLabel.textColor = .tintGreen
        tipLabel.textAlignment = .center
        tipLabel.font = UIFont.systemFont(ofSize: 14)
    }

    @objc private func clickQQLogin() {
        if TencentOpenAPITool.shared.isSupportQQLogin() {
            if !TencentOpenAPITool.shared.login() {
                presentAlert(title: "登录失败", message: "未知错误", on: self)
            }
        } else {
            presentAlert(title: "登录失败", message: "手机未安装QQ", on: self)
        }
    }

    @objc private func clickAppleLogin() {
        AppleLoginTool.shared.login()
    }

    @objc private func clickUIDLogin(button: UIButton) {
        guard let uid = uidTextField.text,
              let password = pwdTextField.text,
              uid.count > 0,
              password.count > 0
        else {
            presentAlert(title: "请填写完整信息", on: self)
            return
        }
        uidTextField.resignFirstResponder()
        pwdTextField.resignFirstResponder()
        button.isEnabled = false
        let alert = UIAlertController(title: "正在登录", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "取消", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
        let config = WebAPIConfig(subspec: "user", function: "login")
        let param = [
            "type": "password",
            "UID": uid,
            "password": password
        ]
        NetworkMgr.shared.request(config: config, parameters: param).responseModel { (result: NetworkResult<BackDataWrapper<LoginBackData>>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    if res.code == 0, let token = res.data?.token {
                        UserConfigMgr.shared.saveValue(token, to: .token)
                        alert.dismiss(animated: true) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        alert.title = "登录失败"
                        alert.message = res.msg
                    }
                case .failure(_):
                    alert.title = "网络请求失败"
                }
                button.isEnabled = true
            }
        }
    }

    @objc private func didQQLogin(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let openId = userInfo["openId"] as? String else { return }
        let config = WebAPIConfig(subspec: "user", function: "login")
        let param = [
            "type": "qq",
            "openID": openId
        ]
        NetworkMgr.shared.request(config: config, parameters: param).responseModel { (result: NetworkResult<BackDataWrapper<LoginBackData>>) in
            switch result {
            case .success(let res):
                if res.code == 0, let token = res.data?.token {
                    UserConfigMgr.shared.saveValue(token, to: .token)
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    presentAlert(title: "登录失败", message: res.msg, on: self)
                }
            case .failure(_):
                presentAlert(title: "网络请求失败", on: self)
            }
        }
    }

    @objc private func didAppleLogin(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let userIdentifier = userInfo["userIdentifier"] as? String else { return }
        let config = WebAPIConfig(subspec: "user", function: "loginWithApple")
        let param = [
            "type": "apple",
            "userIdentifier": userIdentifier
        ]
        NetworkMgr.shared.request(config: config, parameters: param).responseModel { (result: NetworkResult<BackDataWrapper<LoginBackData>>) in
            switch result {
            case .success(let res):
                if res.code == 0, let token = res.data?.token {
                    UserConfigMgr.shared.saveValue(token, to: .token)
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    // 这个接口还没写好，先包一下
                    UserConfigMgr.shared.saveValue("xxxxxxxxxxxxxxxxx", to: .token)
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
//                    presentAlert(title: "登录失败", message: res.msg, on: self)
                }
            case .failure(_):
                // 这个接口还没写好，先包一下
                UserConfigMgr.shared.saveValue("xxxxxxxxxxxxxxxxx", to: .token)
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
//                presentAlert(title: "网络请求失败", on: self)
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

fileprivate struct LoginBackData: Codable {
    var token: String
}
