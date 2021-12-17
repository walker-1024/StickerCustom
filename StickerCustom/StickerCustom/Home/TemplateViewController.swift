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

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
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
        imageView.image = UIImage(data: template.image!)
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
    }

    @objc private func clickGenerate(button: UIButton) {
        guard let qq = Int(qqTextField.text ?? "") else {
            presentAlert(title: "请输入正确的QQ号", message: nil, on: self)
            return
        }
        guard let url = URL(string: "http://q1.qlogo.cn/g?b=qq&nk=\(qq)&s=640") else { return }
        button.isEnabled = false
        DispatchQueue.global().async {
            if let avatarData = try? Data(contentsOf: url) {
                if let avatar = UIImage(data: avatarData)?.resizeImage(size: CGSize(width: 100, height: 100)) {
                    let backImage = UIImage(data: self.template.image!)!

                    let format = UIGraphicsImageRendererFormat()
                    format.opaque = true
                    let renderer = UIGraphicsImageRenderer(size: backImage.size, format: format)
                    let newImage = renderer.image { context in
                        backImage.draw(at: .zero)
                        avatar.draw(at: CGPoint(x: 30, y: 200))
                    }
                    DispatchQueue.main.async {
                        self.imageView.image = newImage
                    }
                } else {
                    presentAlert(title: "获取头像图片失败", message: nil, on: self)
                }
            } else {
                presentAlert(title: "获取头像图片失败", message: nil, on: self)
            }
            DispatchQueue.main.async {
                button.isEnabled = true
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
