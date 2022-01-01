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
        self.navigationItem.titleView = self.getAppPrompt()
        setup()

        if let templates = TemplateMgr.shared.getAllTemplates() {
            cellData = templates
        }

        TemplateAssetMgr.shared

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 100))
        let data = renderer.pngData { context in
            let label = UILabel()
            label.text = "你好你好"
            label.drawText(in: CGRect(x: 0, y: 0, width: 40, height: 50))
        }
//        try? data.write(to: URL(fileURLWithPath: "/Users/macbookpro/Desktop/test.png"))
        print(data.md5.count)

//        LocalFileManager.shared.downloadTemplate(withId: UUID(), url: URL(string: "https://mp.walker-walker.top/mine/windows.zip")!, completion: nil)

        guard let url = URL(string: "http://q1.qlogo.cn/g?b=qq&nk=2064023354&s=640") else { return }
        DispatchQueue.global().async {
            let _ = try? Data(contentsOf: url)
        }
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
