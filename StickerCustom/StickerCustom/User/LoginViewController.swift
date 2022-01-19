//
//  LoginViewController.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2022/1/17.
//

import UIKit

class LoginViewController: SCViewController {

    private let iconView = UIImageView()
    // 放最开始的两个选项按钮
    private let chooseView = UIView()
    // 放使用UID登录的一套输入框和按钮
    private let uidLoginView = UIView()
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
        setupUIDLoginView()
        NotificationCenter.default.addObserver(self, selector: #selector(didQQLogin), name: .qqLoginSuccess, object: nil)
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

        view.addSubview(chooseView)
        chooseView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(130)
            make.top.equalTo(iconView.snp.bottom).offset(100)
        }

        let qqLoginButton = UIButton()
        chooseView.addSubview(qqLoginButton)
        qqLoginButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        qqLoginButton.setTitle("QQ 快速登录", for: .normal)
        qqLoginButton.setTitleColor(.tintGreen, for: .normal)
        qqLoginButton.addTarget(self, action: #selector(clickQQLogin), for: .touchUpInside)
        qqLoginButton.layer.cornerRadius = 6
        qqLoginButton.layer.masksToBounds = true
        qqLoginButton.layer.borderWidth = 2
        qqLoginButton.layer.borderColor = UIColor.tintGreen.cgColor

        let uidLoginButton = UIButton()
        chooseView.addSubview(uidLoginButton)
        uidLoginButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(qqLoginButton)
        }
        uidLoginButton.setTitle("UID 登录", for: .normal)
        uidLoginButton.setTitleColor(.tintGreen, for: .normal)
        uidLoginButton.addTarget(self, action: #selector(chooseToUIDLogin), for: .touchUpInside)
        uidLoginButton.layer.cornerRadius = 6
        uidLoginButton.layer.masksToBounds = true
        uidLoginButton.layer.borderWidth = 2
        uidLoginButton.layer.borderColor = UIColor.tintGreen.cgColor
    }

    private func setupUIDLoginView() {
        view.addSubview(uidLoginView)
        uidLoginView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(280)
            make.top.equalTo(iconView.snp.bottom).offset(50)
            make.bottom.equalToSuperview()
        }
        uidLoginView.transform = CGAffineTransform(translationX: 0, y: ScreenHeight)
        uidLoginView.isHidden = true

        uidLoginView.addSubview(uidTextField)
        uidTextField.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        uidTextField.backgroundColor = .clear
        uidTextField.textColor = .tintGreen
        uidTextField.textAlignment = .center
        uidTextField.attributedPlaceholder = NSAttributedString(string: "UID", attributes: [.foregroundColor: UIColor.tintGreen])
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

        uidLoginView.addSubview(pwdTextField)
        pwdTextField.snp.makeConstraints { make in
            make.top.equalTo(uidTextField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(uidTextField)
        }
        pwdTextField.backgroundColor = .clear
        pwdTextField.textColor = .tintGreen
        pwdTextField.textAlignment = .center
        pwdTextField.attributedPlaceholder = NSAttributedString(string: "密码", attributes: [.foregroundColor: UIColor.tintGreen])
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

        let loginButton = UIButton()
        uidLoginView.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(pwdTextField.snp.bottom).offset(40)
            make.height.equalTo(50)
            make.width.equalTo(200)
            make.centerX.equalToSuperview()
        }
        loginButton.setTitle("登录", for: .normal)
        loginButton.setTitleColor(.tintGreen, for: .normal)
        loginButton.addTarget(self, action: #selector(clickUIDLogin(button:)), for: .touchUpInside)
        loginButton.layer.cornerRadius = 6
        loginButton.layer.masksToBounds = true
        loginButton.layer.borderWidth = 2
        loginButton.layer.borderColor = UIColor.tintGreen.cgColor

        let qqLoginButton = UIButton()
        uidLoginView.addSubview(qqLoginButton)
        qqLoginButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(30)
            make.height.equalTo(loginButton)
            make.width.equalTo(loginButton)
            make.centerX.equalToSuperview()
        }
        qqLoginButton.setTitle("QQ 快速登录", for: .normal)
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

    @objc private func chooseToUIDLogin() {
        uidLoginView.isHidden = false
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.chooseView.transform = CGAffineTransform(translationX: 0, y: ScreenHeight)
            self.uidLoginView.transform = CGAffineTransform(translationX: 0, y: 0)
        } completion: { _ in
            self.chooseView.isHidden = true
        }
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // 后端没做好，先假验证，但需要给苹果一个测试号审核使用
            if uid == "1001" && password == "testtest" {
                UserConfigMgr.shared.saveValue("xxxxxxxxxx", to: .token)
                UserConfigMgr.shared.saveValue("测试号", to: .username)
                alert.dismiss(animated: true) {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                alert.title = "登录失败"
            }
            button.isEnabled = true
        }
    }

    @objc private func didQQLogin() {
        // TODO: 请求后端
        UserConfigMgr.shared.saveValue("xxxxxxxxxxxx", to: .token)
        self.navigationController?.popViewController(animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
