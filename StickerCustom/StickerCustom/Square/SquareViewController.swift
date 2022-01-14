//
//  SquareViewController.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2022/1/2.
//

import UIKit

fileprivate let TemplateCellIdentifier = "SquareTemplateCellIdentifier"

class SquareViewController: SCViewController {

    private var cellData: [TemplateModel] = []

    private var collectionView: UICollectionView!
    private var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "模板广场"
        setup()
        refresh()
    }

    private func setup() {

        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "下拉刷新", attributes: [.foregroundColor: UIColor.tintGreen])
        refreshControl.tintColor = .tintGreen
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)

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
        collectionView.refreshControl = refreshControl
    }

    @objc private func refresh() {
        if !refreshControl.isRefreshing {
            refreshControl.beginRefreshing()
        }
        let config = WebAPIConfig(subspec: "template", function: "getAllTemplate")
        NetworkMgr.shared.request(config: config).responseModel { (result: NetworkResult<BackDataWrapper<TemplateBackData>>) in
            switch result {
            case .success(let model):
                if model.code == 0, let backTemplates = model.data?.templates {
                    var allTemplates: [TemplateModel] = []
                    for item in backTemplates {
                        // TODO: TODO
                        if item.author == "nil" { continue }
                        guard let templateId = UUID(uuidString: item.templateID) else { continue }
                        guard let coverUrl = URL(string: item.cover) else { continue }
                        guard let coverData = try? Data(contentsOf: coverUrl) else { continue }
                        let template = TemplateModel(
                            templateId: templateId,
                            title: item.title,
                            code: item.code,
                            cover: coverData,
                            author: item.author,
                            downloadUrl: URL(string: item.file)
                        )
                        allTemplates.append(template)
                    }
                    DispatchQueue.main.async {
                        self.cellData = allTemplates
                        self.collectionView.reloadData()
                    }
                }
            case .failure(_):
                break
            }
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }

}

extension SquareViewController: UICollectionViewDelegate, UICollectionViewDataSource {

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
        let vc = SquareTemplateViewController()
        vc.template = cellData[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

fileprivate struct TemplateBackData: Codable {
    struct Template: Codable {
        var templateID: String
        var title: String
        var code: String
        var author: String
        var cover: String
        var file: String
    }
    var templates: [Template]
}
