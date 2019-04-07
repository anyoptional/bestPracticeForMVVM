//
//  GLarkAudioHeaderView.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate

/// 音乐界面段头
class GLarkAudioHeaderView: UICollectionReusableView {
    
    private lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.text = "音乐推荐"
        v.textAlignment = .left
        v.textColor = GLarkdef.black_333345
        v.font = UIFont.boldSystemFont(ofSize: 17)
        addSubview(v)
        return v
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.sizeToFit()
        titleLabel.left = 10
        titleLabel.centerY = height / 2
    }
}
