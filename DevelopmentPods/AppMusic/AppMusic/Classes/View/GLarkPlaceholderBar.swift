//
//  GLarkPlaceholderBar.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import YYKit
import SnapKit
import RxSwift

/// 占位搜索框
class GLarkPlaceholderBar: UIControl {
    
    var placeholderText: String? {
        didSet {
            titleLabel.text = placeholderText
        }
    }
    
    private lazy var imgView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(nameInBundle: "music_search")
        addSubview(v)
        return v
    }()

    private lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.textAlignment = .left
        v.textColor = GLarkdef.gray_B1B2BF
        v.font = UIFont.systemFont(ofSize: 14)
        addSubview(v)
        return v
    }()
    
    init(_ placeholderText: String? = nil) {
        self.placeholderText = placeholderText
        super.init(frame: .zero)
        layer.cornerRadius = 15
        backgroundColor = GLarkdef.gray_F2F3F7
        imgView.snp.makeConstraints { (make) in
            make.left.equalTo(8)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 15, height: 15))
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imgView.snp.right).offset(9)
            make.centerY.equalToSuperview()
            make.right.equalTo(-8)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Reactive where Base: GLarkPlaceholderBar {
    /// 点击搜索框
    var tap: Observable<String?> {
        return base.rx.controlEvent(.touchUpInside)
            .map { [weak base] in base?.placeholderText }
    }
}
