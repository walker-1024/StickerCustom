//
//  HomeViewController.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/15.
//

import UIKit

fileprivate let TemplateCellIdentifier = "TemplateCellIdentifier"

class HomeViewController: SCViewController {

    private var cellData: [TemplateModel] = []

    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "模板列表"
        setup()

        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .needRefreshTemplateList, object: nil)

        TemplateMgr.shared
        TemplateAssetMgr.shared

//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            let permissions = [kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO]
//            TencentOpenAPITool.shared.tencentOAuth.authorize(permissions)
//        }

        guard let url = URL(string: "http://q1.qlogo.cn/g?b=qq&nk=2064023354&s=640") else { return }
        DispatchQueue.global().async {
            let _ = try? Data(contentsOf: url)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    private func setup() {
        let width = (ScreenWidth - 15 * 2 - 8) / 2
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: width, height: width * 1.3)
        layout.minimumInteritemSpacing = 8
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 15, bottom: 0, right: 15)
        collectionView.alwaysBounceVertical = true
        collectionView.register(TemplateCell.self, forCellWithReuseIdentifier: TemplateCellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self

        let addButton = UIButton()
        view.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.trailing.equalTo(-35)
            make.bottom.equalTo(-90)
        }
        addButton.backgroundColor = UIColor.buttonBackgroundDark
        addButton.setImage("icon-add-template".localImage, for: .normal)
        addButton.addTarget(self, action: #selector(clickAdd), for: .touchUpInside)
        addButton.layer.cornerRadius = 30
        addButton.layer.masksToBounds = true
    }

    @objc private func clickAdd() {
        let alert = UIAlertController(title: "新建模板", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "输入新建模板标题"
        }
        let ok = UIAlertAction(title: "确定", style: .default) { _ in
            guard let title = alert.textFields?.first?.text else { return }
            guard title.count > 0 else { return }
            let template = TemplateModel(
                title: title,
                code: "// 在这里编辑代码",
                cover: "icon-default-cover".localImage!.pngData()!,
                author: "version1.0"
            )
            TemplateMgr.shared.add(template: template)
            let vc = TemplateViewController()
            vc.template = template
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    @objc private func refresh() {
        DispatchQueue.global().async {
            if let templates = TemplateMgr.shared.getAllTemplates() {
                DispatchQueue.main.async {
                    self.cellData = templates
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TemplateCellIdentifier, for: indexPath)
        if let theCell = cell as? TemplateCell {
            theCell.setupData(data: cellData[indexPath.row])
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = TemplateViewController()
        vc.template = cellData[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
