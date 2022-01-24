//
//  TemplateCell.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/16.
//

import UIKit

class TemplateCell: UICollectionViewCell {

    private var templateId: UUID?

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
        titleBackgroundView.backgroundColor = .templateCellTitleBackgroundDark

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
        templateId = data.templateId
        titleLabel.text = data.title
        if let coverData = data.cover {
            coverImageView.image = UIImage(data: coverData)
        } else {
            coverImageView.image = "icon-default-cover".localImage
        }
    }

    func setupData(data: SquareTemplateModel) {
        templateId = data.templateId
        titleLabel.text = data.title
        if let gifCoverData = LocalFileManager.shared.getGifCover(name: data.templateId.uuidString) {
            DispatchQueue.global().async {
                guard let image = GifProcessor.shared.getImage(from: gifCoverData) else { return }
                DispatchQueue.main.async {
                    // 保证封面确实是当前cell的，而不是已经被复用了的cell的
                    if self.templateId == data.templateId {
                        self.coverImageView.image = image
                    }
                }
            }
        } else if let coverData = LocalFileManager.shared.getCover(name: data.templateId.uuidString) {
            coverImageView.image = UIImage(data: coverData)
        } else {
            coverImageView.image = "icon-loading-cover".localImage
            DispatchQueue.global().async {
                // 如果cell已经被复用了，就先不用加载它的封面了
                guard self.templateId == data.templateId else { return }
                if let url = data.gifCoverUrl, let gifData = try? Data(contentsOf: url) {
                    guard let image = GifProcessor.shared.getImage(from: gifData) else { return }
                    DispatchQueue.main.async {
                        // 保证封面确实是当前cell的，而不是已经被复用了的cell的
                        if self.templateId == data.templateId {
                            self.coverImageView.image = image
                        }
                    }
                    LocalFileManager.shared.saveGifCover(data: gifData, name: data.templateId.uuidString)
                } else if let url = data.coverUrl, let imgData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        // 保证封面确实是当前cell的，而不是已经被复用了的cell的
                        if self.templateId == data.templateId {
                            self.coverImageView.image = UIImage(data: imgData)
                        }
                    }
                    LocalFileManager.shared.saveCover(data: imgData, name: data.templateId.uuidString)
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        templateId = nil
        coverImageView.image = nil
        titleLabel.text = nil
    }
}
