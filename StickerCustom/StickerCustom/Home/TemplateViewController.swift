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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.refresh()
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
        imageView.contentMode = .scaleAspectFit

        view.addSubview(qqTextField)
        qqTextField.snp.makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalTo(60)
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(40)
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
    }

    private func refresh() {
        DispatchQueue.global().async {
            if let template = TemplateMgr.shared.getTemplate(withId: self.template.templateId) {
                DispatchQueue.main.async {
                    self.template = template
                    self.imageView.image = UIImage(data: template.cover!)
                }
            }
        }
    }

    @objc private func clickReviewCode() {
        let vc = TemplateCodeViewController()
        vc.template = template
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func clickGenerate(button: UIButton) {
        qqTextField.resignFirstResponder()
        guard let qq = Int(qqTextField.text ?? "") else {
            presentAlert(title: "请输入正确的QQ号", message: nil, on: self)
            return
        }

        let alert = UIAlertController(title: "正在生成", message: nil, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        RosParser.shared.parse(code: template.code, qqnum: qq, templateId: self.template.templateId) { (result, rosError) in
            DispatchQueue.main.async {
                let ok = UIAlertAction(title: "确定", style: .default, handler: nil)
                guard rosError == nil else {
                    alert.title = "生成失败"
                    alert.message = rosError?.localizedDescription
                    alert.addAction(ok)
                    return
                }
                guard let result = result as? UIImage else {
                    alert.title = "生成失败"
                    alert.message = "未知错误"
                    alert.addAction(ok)
                    return
                }
                alert.dismiss(animated: true, completion: nil)
                self.imageView.image = result
            }
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
