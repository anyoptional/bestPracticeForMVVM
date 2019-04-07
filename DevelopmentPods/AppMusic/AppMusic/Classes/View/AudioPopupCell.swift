//
//  AudioPopupCell.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import AudioService

protocol AudioPopupCellDelegate: class {
    /// 将要删除歌曲
    func popupCellWillRemoveAudio(_ cell: AudioPopupCell)
}

class AudioPopupCell: UITableViewCell, ValueCell {
    
    weak var delegate: AudioPopupCellDelegate?
    
    private lazy var imgView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(nameInBundle: "audio_list_playing")
        contentView.addSubview(v)
        return v
    }()
    
    private lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.textAlignment = .left
        v.font = UIFont.systemFont(ofSize: 15)
        contentView.addSubview(v)
        return v
    }()
    
    private lazy var deleteButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(nameInBundle: "audio_remove"), for: .normal)
        v.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        v.fd.touchAreaInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        contentView.addSubview(v)
        return v
    }()
    
    @objc private func deleteButtonTapped() {
        delegate?.popupCellWillRemoveAudio(self)
    }
    
    func configureWith(value: MusicInfo) {
        titleLabel.text = value.musicName
    }
    
    func configureWith(flag: Bool) {
        imgView.isHidden = !flag
        if flag {
            titleLabel.textColor = GLarkdef.blue_1687FF
            titleLabel.snp.updateConstraints { (make) in
                make.left.equalTo(imgView.snp.right).offset(5)
            }
        } else {
            titleLabel.textColor = GLarkdef.gray_646580
            titleLabel.snp.updateConstraints { (make) in
                make.left.equalTo(imgView.snp.right).offset(-18)
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildUI()
    }
    
    private func buildUI() {
        selectionStyle = .none
        backgroundColor = .white
        imgView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 18, height: 18))
        }
        deleteButton.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 12, height: 12))
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imgView.snp.right).offset(5)
            make.right.equalTo(deleteButton.snp.left).offset(-10)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
