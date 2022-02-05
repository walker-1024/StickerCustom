//
//  TemplateViewController.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/16.
//

import UIKit
import Photos

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
        setup()
        setupButtons()
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
            make.top.equalTo(StatusBarH + NavBarH + 20)
            make.width.height.equalTo(200)
            make.centerX.equalToSuperview()
        }
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        let ges = UITapGestureRecognizer(target: self, action: #selector(saveImage))
        ges.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(ges)

        let tipLabel = UILabel()
        view.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
        tipLabel.text = "点击图片快速保存"
        tipLabel.textColor = .tintGreen
        tipLabel.textAlignment = .center
        tipLabel.font = UIFont.systemFont(ofSize: 15)
        tipLabel.numberOfLines = 1

        view.addSubview(qqTextField)
        qqTextField.snp.makeConstraints { make in
            make.leading.equalTo(35)
            make.trailing.equalTo(view.snp.centerX).offset(-5)
            make.height.equalTo(60)
            make.top.equalTo(tipLabel.snp.bottom).offset(30)
        }
        if let qqNum = UserConfigMgr.shared.getValue(of: .qqNum) {
            qqTextField.text = "\(qqNum)"
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
            make.leading.equalTo(view.snp.centerX).offset(5)
            make.trailing.equalTo(-35)
            make.height.equalTo(qqTextField)
            make.top.equalTo(qqTextField)
        }
        button.setTitle("生成", for: .normal)
        button.setTitleColor(UIColor.tintGreen, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.tintGreen.cgColor
        button.addTarget(self, action: #selector(clickGenerate), for: .touchUpInside)
    }

    private func setupButtons() {
        let editButton = UIButton()
        view.addSubview(editButton)
        editButton.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.top.equalTo(qqTextField.snp.bottom).offset(50)
            make.trailing.equalTo(view.snp.centerX).offset(-40)
        }
        editButton.setImage("icon-edit".localImage, for: .normal)
        editButton.addTarget(self, action: #selector(clickEditTemplate), for: .touchUpInside)

        let codeButton = UIButton()
        view.addSubview(codeButton)
        codeButton.snp.makeConstraints { make in
            make.width.height.equalTo(editButton)
            make.top.equalTo(editButton)
            make.leading.equalTo(view.snp.centerX).offset(40)
        }
        codeButton.setImage("icon-code".localImage, for: .normal)
        codeButton.addTarget(self, action: #selector(clickReviewCode), for: .touchUpInside)

        let releaseButton = UIButton()
        view.addSubview(releaseButton)
        releaseButton.snp.makeConstraints { make in
            make.width.height.equalTo(editButton)
            make.top.equalTo(editButton.snp.bottom).offset(60)
            make.trailing.equalTo(editButton)
        }
        releaseButton.setImage("icon-release".localImage, for: .normal)
        releaseButton.addTarget(self, action: #selector(clickRelease), for: .touchUpInside)

        let deleteButton = UIButton()
        view.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.width.height.equalTo(editButton)
            make.top.equalTo(releaseButton)
            make.leading.equalTo(codeButton)
        }
        deleteButton.setImage("icon-delete".localImage, for: .normal)
        deleteButton.addTarget(self, action: #selector(clickDelete), for: .touchUpInside)

        let textArr = ["编辑模板信息", "编辑模板代码", "发布到广场", "删除模板"]
        let buttonArr = [editButton, codeButton, releaseButton, deleteButton]
        for i in 0..<buttonArr.count {
            let button = buttonArr[i]
            button.imageEdgeInsets = UIEdgeInsets(top: 80 * 0.2, left: 80 * 0.2, bottom: 80 * 0.2, right: 80 * 0.2)
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor.tintGreen.cgColor
            button.layer.cornerRadius = 80 * 0.5
            button.layer.masksToBounds = true

            let label = UILabel()
            view.addSubview(label)
            label.snp.makeConstraints { make in
                make.top.equalTo(button.snp.bottom)
                make.centerX.equalTo(button)
                make.height.equalTo(35)
            }
            label.text = textArr[i]
            label.textColor = UIColor.tintGreen
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14)
            label.numberOfLines = 1
        }
    }

    private func refresh() {
        DispatchQueue.global().async {
            if let template = TemplateMgr.shared.getTemplate(withId: self.template.templateId) {
                DispatchQueue.main.async {
                    self.template = template
                    if let coverData = template.cover {
                        self.imageView.image = GifProcessor.shared.getImage(from: coverData)
                    } else {
                        self.imageView.image = "icon-default-cover".localImage
                    }
                }
            }
        }
    }

    @objc private func saveImage() {
        guard let image = imageView.image else { return }
        if let allImages = image.images {
            PHPhotoLibrary.shared().performChanges {
                let gifPath = LocalFileManager.shared.getTempPath(suffix: "gif")
                let eachDuration = image.duration / Double(allImages.count)
                GifProcessor.shared.createGif(with: allImages, eachDuration: eachDuration, savePath: gifPath)

                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL(fileURLWithPath: gifPath))
            } completionHandler: { isSuccess, error in
                DispatchQueue.main.async {
                    if isSuccess {
                        let alert = UIAlertController(title: "保存成功", message: nil, preferredStyle: .alert)
                        self.present(alert, animated: false, completion: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            alert.dismiss(animated: true, completion: nil)
                        }
                    } else {
                        presentAlert(title: "保存失败", message: nil, on: self)
                    }
                }
            }
        } else {
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { isSuccess, error in
                DispatchQueue.main.async {
                    if isSuccess {
                        let alert = UIAlertController(title: "保存成功", message: nil, preferredStyle: .alert)
                        self.present(alert, animated: false, completion: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            alert.dismiss(animated: true, completion: nil)
                        }
                    } else {
                        presentAlert(title: "保存失败", message: nil, on: self)
                    }
                }
            }
        }
    }

    @objc private func clickEditTemplate() {
        let vc = EditTemplateViewController()
        vc.template = self.template
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func clickReviewCode() {
        let vc = TemplateCodeViewController()
        vc.template = template
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func clickRelease() {
        presentAlert(title: "功能暂未开放", message: nil, on: self)
        return
        let alert = UIAlertController(title: "上传中", message: nil, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.global().async {
            LocalFileManager.shared.archiveTemplate(withId: self.template.templateId) { archiveData, errMsg in
                guard let archiveData = archiveData else {
                    DispatchQueue.main.async {
                        alert.title = "上传失败"
                        alert.message = errMsg
                        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                    }
                    return
                }

                let config = WebAPIConfig(subspec: "template", function: "uploadTemplate")
                let param = [
                    "templateID": self.template.templateId.uuidString,
                    "title": self.template.title,
                    "code": self.template.code
                ]
                guard let paramData = try? JSONEncoder().encode(param) else {
                    DispatchQueue.main.async {
                        alert.title = "上传失败"
                        alert.message = "未知错误"
                        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                    }
                    return
                }

                guard let coverData = self.template.cover else {
                    DispatchQueue.main.async {
                        alert.title = "上传失败"
                        alert.message = "请先设置模板封面"
                        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                    }
                    return
                }

                let paramUploadData = UploadData(key: "param", data: paramData)
                // TODO: 如果封面是动图，则必现上传失败，报错为connection was lost
                // 目前猜测是后端不支持传 gif Data 导致
                // 如果需要用此接口，可以先把下一行的 coverData 换成 Data() 即可正常请求
                let coverFile = UploadFile(key: "cover", data: coverData, fileName: "cover", mimeType: "image/png")
                let archiveFile = UploadFile(key: "file", data: archiveData, fileName: "file", mimeType: "application/zip")
                NetworkMgr.shared.upload(config: config, parameters: [paramUploadData], files: [coverFile, archiveFile], headers: ["Content-Type": "multipart/form-data"]) { (result: NetworkResult<BackDataWrapper<CommonBackData>>) in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let model):
                            if model.code == 0 {
                                alert.title = "上传成功"
                                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                            } else if model.code == 2001 {
                                alert.title = "模板已存在"
                                alert.message = "是否覆盖上传"
                                let overwrite = UIAlertAction(title: "是", style: .destructive) { _ in
                                    self.overwriteRelease(paramUploadData, coverFile, archiveFile)
                                }
                                let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                                alert.addAction(overwrite)
                                alert.addAction(cancel)
                            } else {
                                alert.title = "上传失败"
                                alert.message = model.msg
                                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                            }
                        case .failure(_):
                            alert.title = "网络请求失败"
                            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                        }
                    }
                }
            }
        }
    }

    private func overwriteRelease(_ paramUploadData: UploadData, _ coverFile: UploadFile, _ archiveFile: UploadFile) {
        let alert = UIAlertController(title: "上传中", message: nil, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        let config = WebAPIConfig(subspec: "template", function: "modifyTemplate")
        NetworkMgr.shared.upload(config: config, parameters: [paramUploadData], files: [coverFile, archiveFile], headers: ["Content-Type": "multipart/form-data"]) { (result: NetworkResult<BackDataWrapper<CommonBackData>>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    if model.code == 0 {
                        alert.title = "上传成功"
                    } else {
                        alert.title = "上传失败"
                        alert.message = model.msg
                    }
                case .failure(_):
                    alert.title = "网络请求失败"
                }
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
            }
        }
    }

    @objc private func clickDelete() {
        let alert = UIAlertController(title: "删除模板", message: "删除后将无法恢复", preferredStyle: .alert)
        let ok = UIAlertAction(title: "删除", style: .destructive) { _ in
            TemplateMgr.shared.delete(templateIds: [self.template.templateId])
            self.navigationController?.popViewController(animated: true)
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
//        let tmp = UIAlertAction(title: "tmp", style: .default) { _ in
//            let config = WebAPIConfig(subspec: "template", function: "deleteTemplate")
//            NetworkMgr.shared.request(config: config, placeholders: ["uuid": self.template.templateId.uuidString]).responseString { str in
//                print(str)
//            }
//        }
//        alert.addAction(tmp)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    @objc private func clickGenerate(button: UIButton) {
        qqTextField.resignFirstResponder()
        guard let qq = Int(qqTextField.text ?? "") else {
            presentAlert(title: "请输入正确的QQ号", message: nil, on: self)
            return
        }
        UserConfigMgr.shared.saveValue(qq, to: .qqNum)

        let alert = UIAlertController(title: "正在生成", message: nil, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        RosParser.shared.parse(code: template.code, qqnum: qq, templateId: self.template.templateId) { (result, rosError) in
            DispatchQueue.main.async {
                let ok = UIAlertAction(title: "确定", style: .default, handler: nil)
                guard rosError == nil else {
                    alert.title = "生成失败"
                    alert.message = rosError?.message
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
