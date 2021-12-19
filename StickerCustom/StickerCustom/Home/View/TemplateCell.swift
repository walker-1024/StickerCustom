//
//  TemplateCell.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/16.
//

import UIKit

class TemplateCell: UICollectionViewCell {

    private let coverImageView = UIImageView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = .blue
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        let backView = UIView()
        contentView.addSubview(backView)
        backView.snp.makeConstraints { make in
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
            make.top.equalTo(10)
            make.bottom.equalTo(-10)
        }
        backView.layer.cornerRadius = 10
        backView.layer.masksToBounds = true

        backView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(coverImageView.snp.width)
        }
        coverImageView.contentMode = .scaleAspectFill

        let titleBackgroundView = UIView()
        backView.addSubview(titleBackgroundView)
        titleBackgroundView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(coverImageView.snp.bottom)
        }
        titleBackgroundView.backgroundColor = .tintDark

        titleBackgroundView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.centerY.equalToSuperview()
        }
        titleLabel.textColor = .tintGreen
        titleLabel.font = UIFont.systemFont(ofSize: 23)
    }

    func setupData(data: TemplateModel) {
        coverImageView.image = UIImage(data: data.cover!)
        titleLabel.text = data.title
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.image = nil
        titleLabel.text = nil
    }
}
