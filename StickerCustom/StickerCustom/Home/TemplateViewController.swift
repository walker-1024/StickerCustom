//
//  TemplateViewController.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/16.
//

import UIKit

fileprivate let TextFieldFont = UIFont.systemFont(ofSize: 18)

class TemplateViewController: SCViewController {

    var template: TemplateModel!

    private let imageView = UIImageView()
    private let qqTextField = UITextField()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton()
        button.setTitle("查看代码", for: .normal)
        button.addTarget(self, action: #selector(clickReviewCode), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(receiveResult(notification:)), name: .tmp, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        qqTextField.resignFirstResponder()
    }

    private func setup() {
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(150)
            make.width.height.equalTo(200)
            make.centerX.equalToSuperview()
        }
        imageView.image = UIImage(data: template.cover!)
        imageView.contentMode = .scaleAspectFit

        view.addSubview(qqTextField)
        qqTextField.snp.makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalTo(60)
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(30)
        }
        qqTextField.attributedPlaceholder = NSAttributedString(string: "输入QQ号", attributes: [.foregroundColor: UIColor.tintGreen])
        qqTextField.textColor = UIColor.tintGreen
        qqTextField.textAlignment = .center
        qqTextField.font = TextFieldFont
        qqTextField.keyboardType = .default
        qqTextField.returnKeyType = .done
        qqTextField.autocorrectionType = .no
        qqTextField.autocapitalizationType = .none
        qqTextField.delegate = self
        qqTextField.layer.borderWidth = 2
        qqTextField.layer.borderColor = UIColor.tintGreen.cgColor
        qqTextField.layer.cornerRadius = 6
        qqTextField.layer.masksToBounds = true

        let button = UIButton()
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.width.equalTo(150)
            make.height.equalTo(60)
            make.centerX.equalToSuperview()
            make.top.equalTo(qqTextField.snp.bottom).offset(30)
        }
        button.setTitle("生成", for: .normal)
        button.setTitleColor(UIColor.tintGreen, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.tintGreen.cgColor
        button.addTarget(self, action: #selector(clickGenerate), for: .touchUpInside)

        let textView = UITextView()
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(qqTextField)
            make.top.equalTo(button.snp.bottom).offset(30)
            make.bottom.equalTo(-60)
        }
        textView.backgroundColor = .clear
        textView.text = template.code
        textView.textColor = UIColor.tintGreen
        textView.font = TextFieldFont
        textView.layer.borderWidth = 2
        textView.layer.borderColor = UIColor.tintGreen.cgColor
        textView.layer.cornerRadius = 10
        textView.layer.masksToBounds = true
        textView.isUserInteractionEnabled = false
    }

    @objc private func clickReviewCode() {
        let vc = TemplateCodeViewController()
        vc.template = template
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func clickGenerate(button: UIButton) {
        guard let qq = Int(qqTextField.text ?? "") else {
            presentAlert(title: "请输入正确的QQ号", message: nil, on: self)
            return
        }

        RosParser.shared.parse(code: template.code, qqnum: qq)
    }

    @objc private func receiveResult(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let result = userInfo["result"] as? UIImage else { return }
        DispatchQueue.main.async {
            self.imageView.image = result
        }
    }
}

extension TemplateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return string.isIntNumber || string.count == 0
    }
}
