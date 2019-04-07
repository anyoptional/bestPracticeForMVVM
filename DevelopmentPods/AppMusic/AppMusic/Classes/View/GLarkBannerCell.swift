//
//  GLarkBannerCell.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import SDWebImage

class GLarkBannerCell: UICollectionViewCell, ValueCell {
        
    fileprivate lazy var imgView: UIImageView = {
        let v = UIImageView()
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 4
        v.contentMode = .scaleAspectFill
        contentView.addSubview(v)
        return v
    }()
    
    fileprivate lazy var shadowLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor
        layer.shadowOffset = CGSize(width: 3.5, height: 5.5)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 5.5
        contentView.layer.insertSublayer(layer, at: 0)
        return layer
    }()
    
    func configureWith(value: String?) {
        let key = value.filterNil()
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgView.left = 10
        imgView.top = 10
        imgView.width = width - 20
        imgView.height = height - 25
        
        shadowLayer.left = imgView.left + 3
        shadowLayer.top = imgView.top
        shadowLayer.width = imgView.width - 6
        shadowLayer.height = imgView.height - 2
    }
}

