//
//  EditTemplateViewController.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2022/1/2.
//

import UIKit

class EditTemplateViewController: SCViewController {

    var template: TemplateModel!

    private let coverImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "编辑模板信息"
        setup()
    }

    private func setup() {
        view.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.top.equalTo(StatusBarH + NavBarH + 20)
            make.width.height.equalTo(150)
            make.centerX.equalToSuperview()
        }
        coverImageView.image = UIImage(data: template.cover)
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.isUserInteractionEnabled = true
        let ges = UITapGestureRecognizer(target: self, action: #selector(clickChangeCover))
        ges.numberOfTapsRequired = 1
        coverImageView.addGestureRecognizer(ges)

        let tipLabel = UILabel()
        view.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.top.equalTo(coverImageView.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalTo(45)
        }
        tipLabel.text = "点击图片修改封面"
        tipLabel.textColor = .tintGreen
        tipLabel.textAlignment = .center
        tipLabel.font = UIFont.systemFont(ofSize: 15)
        tipLabel.numberOfLines = 1

        let renameButton = UIButton()
        view.addSubview(renameButton)
        renameButton.snp.makeConstraints { make in
            make.top.equalTo(tipLabel.snp.bottom).offset(30)
            make.width.equalTo(160)
            make.height.equalTo(60)
            make.centerX.equalToSuperview()
        }
        renameButton.setTitle("修改模板标题", for: .normal)
        renameButton.setTitleColor(.tintGreen, for: .normal)
        renameButton.addTarget(self, action: #selector(clickRename), for: .touchUpInside)
        renameButton.layer.cornerRadius = 8
        renameButton.layer.masksToBounds = true
        renameButton.layer.borderWidth = 2
        renameButton.layer.borderColor = UIColor.tintGreen.cgColor
    }

    @objc private func clickRename() {
        let alert = UIAlertController(title: "修改标题", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = self.template.title
        }
        let ok = UIAlertAction(title: "确定", style: .default) { _ in
            guard let newTitle = alert.textFields?.first?.text else { return }
            self.template.title = newTitle
            TemplateMgr.shared.modify(template: self.template)
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    @objc private func clickChangeCover() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
    }
}

extension EditTemplateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage, let imageData = image.pngData() {
            self.template.cover = imageData
            TemplateMgr.shared.modify(template: self.template)
            self.coverImageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
