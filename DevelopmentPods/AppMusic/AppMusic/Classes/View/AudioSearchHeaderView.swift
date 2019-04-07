//
//  AudioSearchHeaderView.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate

protocol AudioSearchHeaderViewDelegate: class {
    /// 将要删除历史记录
    func audioSearchHeaderViewWillClearSearchHistory(_ headerView: AudioSearchHeaderView)
}

class AudioSearchHeaderView: UIView {
    
    weak var delegate: AudioSearchHeaderViewDelegate?
    
    private lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 14)
        v.textColor = GLarkdef.gray_B1B2BF
        v.textAlignment = .left
        v.text = "搜索历史"
        addSubview(v)
        return v
    }()
    
    private lazy var eventButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(nameInBundle: "audio_clear_list"), for: .normal)
        v.fd.touchAreaInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        v.addTarget(self, action: #selector(eventButtonTapped), for: .touchUpInside)
        addSubview(v)
        return v
    }()
    
    @objc private func eventButtonTapped() {
        delegate?.audioSearchHeaderViewWillClearSearchHistory(self)
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.centerY.equalToSuperview().offset(2)
        }
        eventButton.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
