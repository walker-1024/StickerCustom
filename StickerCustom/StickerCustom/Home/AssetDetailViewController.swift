//
//  AssetDetailViewController.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/28.
//

import UIKit

class AssetDetailViewController: SCViewController {

    var asset: TemplateAssetModel!

    let nameButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = asset.name
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func setup() {
        let imageView = UIImageView()
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.equalTo(50)
            make.trailing.equalTo(-50)
            make.top.equalTo(StatusBarH + NavBarH)
            make.height.equalTo(imageView.snp.width)
        }
        switch asset.assetType {
        case .png:
            imageView.image = UIImage(data: asset.data)
        case .gif:
            break
        }
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true

        guard let image = UIImage(data: asset.data) else { return }

        view.addSubview(nameButton)
        nameButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.height.equalTo(60)
            make.width.equalTo(300)
            make.centerX.equalToSuperview()
        }
        nameButton.setTitle("图片名：\(asset.name)", for: .normal)
        let widthButton = UIButton()
        view.addSubview(widthButton)
        widthButton.snp.makeConstraints { make in
            make.top.equalTo(nameButton.snp.bottom).offset(10)
            make.width.height.equalTo(nameButton)
            make.centerX.equalToSuperview()
        }
        widthButton.setTitle("图片宽度：\(image.size.width)", for: .normal)
        let heightButton = UIButton()
        view.addSubview(heightButton)
        heightButton.snp.makeConstraints { make in
            make.top.equalTo(widthButton.snp.bottom).offset(10)
            make.width.height.equalTo(nameButton)
            make.centerX.equalToSuperview()
        }
        heightButton.setTitle("图片高度：\(image.size.height)", for: .normal)

        let renameButton = UIButton()
        view.addSubview(renameButton)
        renameButton.snp.makeConstraints { make in
            make.top.equalTo(heightButton.snp.bottom).offset(10)
            make.width.height.equalTo(nameButton)
            make.centerX.equalToSuperview()
        }
        renameButton.setTitle("重命名", for: .normal)
        renameButton.addTarget(self, action: #selector(clickRename), for: .touchUpInside)

        let deleteButton = UIButton()
        view.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(renameButton.snp.bottom).offset(10)
            make.width.height.equalTo(nameButton)
            make.centerX.equalToSuperview()
        }
        deleteButton.setTitle("删除素材", for: .normal)
        deleteButton.addTarget(self, action: #selector(clickDelete), for: .touchUpInside)

        for button in [nameButton, widthButton, heightButton, renameButton, deleteButton] {
            button.setTitleColor(.tintGreen, for: .normal)
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.tintGreen.cgColor
            button.layer.masksToBounds = true
        }

    }

    @objc private func clickRename() {
        let alert = UIAlertController(title: "重命名", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        let ok = UIAlertAction(title: "确定", style: .default) { _ in
            guard let newName = alert.textFields?.first?.text else { return }
            self.asset.name = newName
            TemplateAssetMgr.shared.modify(templateAsset: self.asset)
            self.nameButton.setTitle("图片名：\(newName)", for: .normal)
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    @objc private func clickDelete() {
        let alert = UIAlertController(title: "删除素材", message: "删除后将无法恢复", preferredStyle: .alert)
        let ok = UIAlertAction(title: "删除", style: .destructive) { _ in
            TemplateAssetMgr.shared.delete(templateAsset: self.asset)
            self.navigationController?.popViewController(animated: true)
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

}
