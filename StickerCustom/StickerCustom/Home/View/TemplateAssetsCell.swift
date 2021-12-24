//
//  TemplateAssetsCell.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/24.
//

import UIKit

class TemplateAssetsCell: UICollectionViewCell {

    private var imageName: String?

    private let coverImageView = UIImageView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        contentView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.leading.equalTo(5)
            make.trailing.equalTo(-5)
            make.top.equalTo(5)
            make.height.equalTo(coverImageView.snp.width)
        }
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.layer.cornerRadius = 5
        coverImageView.layer.masksToBounds = true

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(coverImageView.snp.bottom)
        }
        titleLabel.textColor = .tintGreen
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 15)
    }

    func setupData(model: TemplateAssetModel?) {
        if let model = model {
            imageName = model.name
            coverImageView.image = UIImage(data: model.data)
            titleLabel.text = model.name
        } else {
            coverImageView.image = "icon-add-assets".localImage
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.image = nil
        titleLabel.text = nil
    }
}
