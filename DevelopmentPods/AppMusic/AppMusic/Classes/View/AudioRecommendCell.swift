//
//  AudioRecommendCell.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import SDWebImage
import AudioService
import SkeletonView

/// 音乐推荐
class AudioRecommendCell: UICollectionViewCell, ValueCell {
    
    private lazy var imgView: UIImageView = {
        let v = UIImageView()
        v.isSkeletonable = true
        v.layer.cornerRadius = 3
        v.layer.masksToBounds = true
        v.contentMode = .scaleAspectFit
        contentView.addSubview(v)
        return v
    }()
    
    private lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.isSkeletonable = true
        v.numberOfLines = 2
        v.textAlignment = .left
        v.textColor = GLarkdef.black_333345
        v.font = UIFont.systemFont(ofSize: 13)
        contentView.addSubview(v)
        return v
    }()
    
    func configureWith(value: MusicSheetInfo) {
        titleLabel.text = value.title
        let key = value.imgUrl.filterNil()
        let fullKey = key + "_resizeAdditions"
        if let image = SDImageCache.shared().imageFromCache(forKey: fullKey) {
            imgView.image = image
        } else {
            imgView.sd_setImage(with: URL(string: key),
                                placeholderImage: nil,
                                options: [.avoidAutoSetImage],
                                completed: { [weak self] (image, error, _, key) in
                                    guard let `self` = self else { return }
                                    if let image = image {
                                        if !self.imgView.isHighlighted { self.imgView.layer.removeAnimation(forKey: "_KFadeAnimationKey") }
                                        let transition = CATransition()
                                        transition.duration = 0.2
                                        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                                        transition.type = .fade
                                        self.imgView.layer.add(transition, forKey: "_KFadeAnimationKey")
                                        let resizedImage = image.byResize(to: CGSize(width: self.width, height: 220))
                                        self.imgView.image = resizedImage
                                        SDImageCache.shared().store(resizedImage, forKey: fullKey, completion: nil)
                                    } else {
                                        self.imgView.image = UIImage(nameInBundle: "banner")
                                    }
            })
        }
    }
    
    private func performBinding() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgView.left = 2.5
        imgView.top = 0
        imgView.width = width - 5
        imgView.height = 220
        
        titleLabel.left = imgView.left
        titleLabel.top = imgView.bottom
        titleLabel.width = imgView.width - 8
        titleLabel.height = 30
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
        performBinding()
    }
    
    private func buildUI() {
        isSkeletonable = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
