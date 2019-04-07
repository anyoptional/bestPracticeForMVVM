//
//  AudioSheetListSectionHeaderView.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import AudioService

protocol AudioSheetListSectionHeaderViewDelegate: class {
    /// 将要完整播放歌单
    func audioStramerWillPlayWholeSheet()
}

class AudioSheetListSectionHeaderView: UIView, ValueCell {

    weak var delegate: AudioSheetListSectionHeaderViewDelegate?
    
    fileprivate lazy var imgView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(nameInBundle: "sheet_header_play")
        v.contentMode = .scaleAspectFit
        addSubview(v)
        return v
    }()
    
    private lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.textAlignment = .left
        v.textColor = GLarkdef.black_333345
        v.font = UIFont.systemFont(ofSize: 16)
        addSubview(v)
        return v
    }()

    private lazy var lineView: UIView = {
        let v = UIView()
        v.backgroundColor = GLarkdef.gray_EAEAEA
        addSubview(v)
        return v
    }()
    
    func configureWith(value: [MusicInfo]) {
        let prefix = "播放全部"
        let suffix = "(共\(value.count)首)"
        let fullString = prefix + suffix
        let attrText = NSMutableAttributedString(string: fullString,
                                                 attributes: [.font : UIFont.systemFont(ofSize: 16),
                                                              .foregroundColor : GLarkdef.black_333345])
        attrText.addAttributes([.font : UIFont.systemFont(ofSize: 13),
                                .foregroundColor : GLarkdef.gray_B1B2BF],
                               range: (fullString as NSString).range(of: suffix))
        titleLabel.attributedText = attrText
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imgView.left = 14
        imgView.width = 20
        imgView.height = 20
        imgView.centerY = height / 2
        
        titleLabel.left = imgView.right + 10
        titleLabel.width = 200
        titleLabel.height = 20
        titleLabel.centerY = imgView.centerY
        
        lineView.left = 0
        lineView.width = width
        lineView.height = 0.5
        lineView.bottom = height
    }
    
    @objc private func onTap() {
        delegate?.audioStramerWillPlayWholeSheet()
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                    action: #selector(onTap)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
