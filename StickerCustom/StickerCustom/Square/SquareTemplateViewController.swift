//
//  SquareTemplateViewController.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2022/1/2.
//

import UIKit

class SquareTemplateViewController: SCViewController {

    var template: SquareTemplateModel!

    private let imageView = UIImageView()

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func setup() {
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(StatusBarH + NavBarH + 20)
            make.width.height.equalTo(200)
            make.centerX.equalToSuperview()
        }
        if let coverData = LocalFileManager.shared.getCover(name: template.templateId.uuidString) {
            imageView.image = UIImage(data: coverData)
        } else {
            imageView.image = "icon-loading-cover".localImage
            guard let url = template.coverUrl else { return }
            DispatchQueue.global().async {
                guard let imgData = try? Data(contentsOf: url) else { return }
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: imgData)
                }
                LocalFileManager.shared.saveCover(data: imgData, name: self.template.templateId.uuidString)
            }
        }
        imageView.contentMode = .scaleAspectFit

        let tipLabel = UILabel()
        view.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalTo(45)
        }
        tipLabel.text = "下载后才可体验"
        tipLabel.textColor = .tintGreen
        tipLabel.textAlignment = .center
        tipLabel.font = UIFont.systemFont(ofSize: 15)
        tipLabel.numberOfLines = 1

        let button = UIButton()
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.width.height.equalTo(90)
            make.top.equalTo(imageView.snp.bottom).offset(80)
            make.centerX.equalToSuperview()
        }
        button.setTitle("下载", for: .normal)
        button.setTitleColor(UIColor.tintGreen, for: .normal)
        button.layer.cornerRadius = 45
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.tintGreen.cgColor
        button.addTarget(self, action: #selector(clickDownload), for: .touchUpInside)
    }

    @objc private func clickDownload() {
        guard let url = self.template.downloadUrl else { return }
        let alert = UIAlertController(title: "正在下载", message: nil, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.global().async {
            LocalFileManager.shared.downloadTemplate(withId: self.template.templateId, url: url) { model, errMessage in
                DispatchQueue.main.async {
                    alert.title = model != nil ? "下载成功" : "下载失败"
                    alert.message = errMessage
                    let ok = UIAlertAction(title: "确定", style: .default, handler: nil)
                    alert.addAction(ok)
                }
            }
        }
    }
}
