//
//  AudioSheetListHeaderView.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import AudioService
import SkeletonView

class AudioSheetListHeaderView: UIView, ValueCell {
    
    // 用来确定何时改变导航栏标题
    var titleLabelFrame: CGRect {
        return titleLabel.frame
    }
    
    private lazy var imgView: UIImageView = {
        let v = UIImageView()
        v.isSkeletonable = true
        v.layer.cornerRadius = 5
        v.layer.masksToBounds = true
        v.contentMode = .scaleAspectFill
        addSubview(v)
        return v
    }()
    
    private lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.isSkeletonable = true
        v.numberOfLines = 2
        v.textAlignment = .left
        v.textColor = .white
        v.font = UIFont.boldSystemFont(ofSize: 17)
        addSubview(v)
        return v
    }()
    
    func configureWith(value: MusicSheetInfo) {
        titleLabel.text = value.title
        imgView.fd.setImage(withURL: URL(string: value.imgUrl.filterNil()))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        isSkeletonable = true
        
        imgView.size = CGSize(width: 110, height: 120)
        imgView.left = 15
        imgView.bottom = height - 15
        
        titleLabel.top = imgView.top
        titleLabel.left = imgView.right + 15
        titleLabel.height = 45
        titleLabel.width = width - titleLabel.left - 30
    }
}
