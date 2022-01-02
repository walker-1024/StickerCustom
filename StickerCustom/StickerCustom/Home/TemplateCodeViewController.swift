//
//  TemplateCodeViewController.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/24.
//

import UIKit

let TemplateAssetsCellIdentifier = "TemplateAssetsCellIdentifier"

class TemplateCodeViewController: SCViewController, UIGestureRecognizerDelegate {

    var template: TemplateModel!

    private var cellData: [TemplateAssetModel] = []

    private var isEdited: Bool = false {
        didSet {
            saveButton.isHidden = !isEdited
        }
    }

    private let previewButton = UIButton()
    private let assetsButton = UIButton()
    private let previewView = UIView()
    private var assetsCollectionView: UICollectionView!
    private let imageView = UIImageView()
    private let qqTextField = UITextField()
    private let codeTextView = UITextView()
    private let saveButton = UIButton()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopbar()
        setupAssetsCollectionView()
        setupPreviewView()
        setupCodeView()
        // 实现在状态栏隐藏的情况下能够右划返回
        // self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.refresh()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        qqTextField.resignFirstResponder()
        codeTextView.resignFirstResponder()
    }

    private func setupTopbar() {
        let topbar = UIView()
        view.addSubview(topbar)
        topbar.translatesAutoresizingMaskIntoConstraints = false
        topbar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(StatusBarH)
            make.height.equalTo(NavBarH)
        }

        let backButton = UIButton()
        topbar.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(60)
        }
        backButton.setImage("icon-back".localImage?.resizeImage(size: CGSize(width: 14, height: 25)), for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 31)
        backButton.addTarget(self, action: #selector(clickBack), for: .touchUpInside)

        topbar.addSubview(previewButton)
        previewButton.snp.makeConstraints { make in
            make.trailing.equalTo(topbar.snp.centerX).offset(-10)
            make.width.equalTo(50)
            make.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
        previewButton.setTitle("预览", for: .normal)
        previewButton.setTitleColor(.tintGreen, for: .selected)
        previewButton.setTitleColor(.gray, for: .normal)
        previewButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        previewButton.isSelected = true
        previewButton.tag = 1
        previewButton.addTarget(self, action: #selector(selectButton(button:)), for: .touchUpInside)

        topbar.addSubview(assetsButton)
        assetsButton.snp.makeConstraints { make in
            make.leading.equalTo(topbar.snp.centerX).offset(10)
            make.width.equalTo(previewButton)
            make.height.equalTo(previewButton)
            make.centerY.equalToSuperview()
        }
        assetsButton.setTitle("素材", for: .normal)
        assetsButton.setTitleColor(.tintGreen, for: .selected)
        assetsButton.setTitleColor(.gray, for: .normal)
        assetsButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        assetsButton.tag = 2
        assetsButton.addTarget(self, action: #selector(selectButton(button:)), for: .touchUpInside)

        topbar.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        saveButton.setTitle("保存", for: .normal)
        saveButton.setTitleColor(.tintGreen, for: .normal)
        saveButton.addTarget(self, action: #selector(clickSave), for: .touchUpInside)
        saveButton.isHidden = true
    }

    private func setupAssetsCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 50, height: 70)
        assetsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.addSubview(assetsCollectionView)
        assetsCollectionView.snp.makeConstraints { make in
            make.leading.equalTo(30)
            make.trailing.equalTo(-30)
            make.top.equalTo(120)
            make.height.equalTo(200)
        }
        assetsCollectionView.backgroundColor = .clear
        assetsCollectionView.alwaysBounceVertical = true
        assetsCollectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        assetsCollectionView.register(TemplateAssetsCell.self, forCellWithReuseIdentifier: TemplateAssetsCellIdentifier)
        assetsCollectionView.delegate = self
        assetsCollectionView.dataSource = self
        assetsCollectionView.layer.cornerRadius = 10
        assetsCollectionView.layer.borderColor = UIColor.tintGreen.cgColor
        assetsCollectionView.layer.borderWidth = 2
        assetsCollectionView.layer.masksToBounds = true
        assetsCollectionView.isHidden = true
        assetsCollectionView.transform = CGAffineTransform(translationX: ScreenWidth, y: 0)
    }

    private func setupPreviewView() {
        view.addSubview(previewView)
        previewView.snp.makeConstraints { make in
            make.leading.equalTo(30)
            make.trailing.equalTo(-30)
            make.top.equalTo(120)
            make.height.equalTo(200)
        }

        previewView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.height.equalTo(160)
            make.centerY.equalToSuperview()
        }
        imageView.image = UIImage(data: template.cover)
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true

        previewView.addSubview(qqTextField)
        qqTextField.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.leading.equalTo(imageView.snp.trailing).offset(20)
            make.top.equalTo(imageView)
            make.bottom.equalTo(imageView.snp.centerY).offset(-10)
        }
        qqTextField.attributedPlaceholder = NSAttributedString(string: "输入QQ号", attributes: [.foregroundColor: UIColor.tintGreen])
        qqTextField.textColor = UIColor.tintGreen
        qqTextField.textAlignment = .center
        qqTextField.font = UIFont.systemFont(ofSize: 18)
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
        previewView.addSubview(button)
        button.snp.makeConstraints { make in
            make.leading.trailing.equalTo(qqTextField)
            make.top.equalTo(imageView.snp.centerY).offset(10)
            make.bottom.equalTo(imageView)
        }
        button.setTitle("生成", for: .normal)
        button.setTitleColor(UIColor.tintGreen, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.tintGreen.cgColor
        button.addTarget(self, action: #selector(clickGenerate), for: .touchUpInside)
    }

    private func setupCodeView() {
        view.addSubview(codeTextView)
        codeTextView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(assetsCollectionView)
            make.top.equalTo(assetsCollectionView.snp.bottom).offset(20)
            make.bottom.equalTo(-20)
        }
        codeTextView.backgroundColor = .clear
        codeTextView.text = self.template?.code
        codeTextView.textColor = UIColor.tintGreen
        codeTextView.font = UIFont.systemFont(ofSize: 18)
        codeTextView.alwaysBounceVertical = true
        codeTextView.keyboardType = .default
        codeTextView.returnKeyType = .done
        codeTextView.autocorrectionType = .no
        codeTextView.autocapitalizationType = .none
        codeTextView.delegate = self
        codeTextView.layer.borderWidth = 2
        codeTextView.layer.borderColor = UIColor.tintGreen.cgColor
        codeTextView.layer.cornerRadius = 10
        codeTextView.layer.masksToBounds = true
    }

    private func refresh() {
        DispatchQueue.global().async {
            if var assets = TemplateAssetMgr.shared.getAllAssets(of: self.template.templateId) {
                assets.sort { $0.time > $1.time }
                DispatchQueue.main.async {
                    self.cellData = assets
                    self.assetsCollectionView.reloadData()
                }
            }
        }
    }

    @objc private func clickGenerate() {
        qqTextField.resignFirstResponder()
        codeTextView.resignFirstResponder()
        guard let qq = Int(qqTextField.text ?? "") else {
            presentAlert(title: "请输入正确的QQ号", message: nil, on: self)
            return
        }

        let alert = UIAlertController(title: "正在生成", message: nil, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        RosParser.shared.parse(code: codeTextView.text, qqnum: qq, templateId: self.template.templateId) { (result, rosError) in
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

    @objc private func selectButton(button: UIButton) {
        if button.tag == 1 {
            if !previewButton.isSelected {
                previewButton.isSelected = true
                assetsButton.isSelected = false
                self.previewView.isHidden = false
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                    self.previewView.transform = CGAffineTransform(translationX: 0, y: 0)
                    self.assetsCollectionView.transform = CGAffineTransform(translationX: ScreenWidth, y: 0)
                } completion: { _ in
                    if !self.assetsButton.isSelected {
                        self.assetsCollectionView.isHidden = true
                    }
                }
            }
        } else {
            if previewButton.isSelected {
                previewButton.isSelected = false
                assetsButton.isSelected = true
            }
            self.assetsCollectionView.isHidden = false
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                self.previewView.transform = CGAffineTransform(translationX: -ScreenWidth, y: 0)
                self.assetsCollectionView.transform = CGAffineTransform(translationX: 0, y: 0)
            } completion: { _ in
                if !self.previewButton.isSelected {
                    self.previewView.isHidden = true
                }
            }
        }
    }

    @objc private func clickBack() {
        if isEdited {
            let alertC = UIAlertController(title: "是否保存修改", message: nil, preferredStyle: .alert)
            let notSave = UIAlertAction(title: "不保存", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            }
            let save = UIAlertAction(title: "保存", style: .default) { _ in
                self.clickSave()
                self.navigationController?.popViewController(animated: true)
            }
            alertC.addAction(notSave)
            alertC.addAction(save)
            self.present(alertC, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @objc private func clickSave() {
        guard var theTemplate = self.template else { return }
        theTemplate.code = codeTextView.text
        TemplateMgr.shared.modify(template: theTemplate)
        self.template = theTemplate
        self.isEdited = false
        qqTextField.resignFirstResponder()
        codeTextView.resignFirstResponder()
    }
}

extension TemplateCodeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellData.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TemplateAssetsCellIdentifier, for: indexPath)
        if let theCell = cell as? TemplateAssetsCell {
            if indexPath.row == 0 {
                theCell.setupData(model: nil)
            } else {
                theCell.setupData(model: cellData[indexPath.row - 1])
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.allowsEditing = true
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }
        } else {
            let vc = AssetDetailViewController()
            vc.asset = self.cellData[indexPath.row - 1]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension TemplateCodeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageData = (info[UIImagePickerController.InfoKey.editedImage] as? UIImage)?.pngData() {
            for i in 0...cellData.count {
                if !cellData.contains(where: { $0.name == String(i) }) {
                    let asset = TemplateAssetModel(templateId: template.templateId, name: String(i), data: imageData, assetType: .png)
                    TemplateAssetMgr.shared.add(templateAsset: asset)
                    self.refresh()
                    break
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension TemplateCodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return string.isIntNumber || string.count == 0
    }
}

extension TemplateCodeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.isEdited = true
    }
}
