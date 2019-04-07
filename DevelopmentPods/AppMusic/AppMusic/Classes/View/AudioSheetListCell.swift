//
//  AudioSheetCell.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import SkeletonView
import AudioService

protocol AudioSheetListCellDelegate: class {
    /// 将要改变是否喜欢
    func sheetListCell(_ cell: AudioSheetListCell, willChangeLikeStatus isLike: Bool)
    /// 将要打开工具箱
    func sheetListCellWillOpenPopupMenu(_ cell: AudioSheetListCell)
}

class AudioSheetListCell: UITableViewCell, ValueCell {
    
    weak var delegate: AudioSheetListCellDelegate?
    
    private lazy var indexLabel: UILabel = {
        let v = UILabel()
        v.isSkeletonable = true
        v.linesCornerRadius = 2
        v.textAlignment = .center
        v.textColor = GLarkdef.gray_9999A2
        v.font = UIFont.systemFont(ofSize: 17)
        contentView.addSubview(v)
        return v
    }()
    
    private lazy var playIv: UIImageView = {
        let v = UIImageView()
        v.isHidden = true
        v.contentMode = .scaleAspectFit
        v.image = UIImage(nameInBundle: "audio_list_playing")
        contentView.addSubview(v)
        return v
    }()
    
    private lazy var nameLabel: UILabel = {
        let v = UILabel()
        v.isSkeletonable = true
        v.linesCornerRadius = 5
        v.textAlignment = .left
        v.textColor = GLarkdef.black_333345
        v.font = UIFont.systemFont(ofSize: 16)
        contentView.addSubview(v)
        return v
    }()
    
    private lazy var artistLabel: UILabel = {
        let v = UILabel()
        v.isSkeletonable = true
        v.linesCornerRadius = 5
        v.textAlignment = .left
        v.textColor = GLarkdef.gray_646580
        v.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(v)
        return v
    }()
    
    private lazy var likeButton: UIButton = {
        let v = UIButton()
        v.isSkeletonable = true
        v.layer.cornerRadius = 7.5
        v.layer.masksToBounds = true
        v.setImage(UIImage(nameInBundle: "sheet_list_unlike"), for: .normal)
        v.setImage(UIImage(nameInBundle: "sheet_list_like"), for: .selected)
        v.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        v.fd.touchAreaInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 5)
        contentView.addSubview(v)
        return v
    }()

    private lazy var moreButton: UIButton = {
        let v = UIButton()
        v.isSkeletonable = true
        v.layer.cornerRadius = 9
        v.layer.masksToBounds = true
        v.setImage(UIImage(nameInBundle: "sheet_list_more"), for: .normal)
        v.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        v.fd.touchAreaInsets = UIEdgeInsets(top: 15, left: 5, bottom: 15, right: 15)
        contentView.addSubview(v)
        return v
    }()
    
    fileprivate let viewModel: AudioSheetListCellViewModelType = AudioSheetListCellViewModel()

    func configureWith(value: MusicInfo) {
        viewModel.inputs.configure(value: value)
        nameLabel.text = viewModel.outputs.nameText
        artistLabel.text = viewModel.outputs.artistText
        likeButton.isSelected = viewModel.outputs.isCollection
        indexLabel.isHidden = viewModel.outputs.isPlaying
        playIv.isHidden = !viewModel.outputs.isPlaying
        if viewModel.outputs.isPlaying {
            nameLabel.textColor = GLarkdef.blue_1687FF
            artistLabel.textColor = GLarkdef.blue_1687FF
        } else {
            nameLabel.textColor = GLarkdef.black_333345
            artistLabel.textColor = GLarkdef.gray_646580
        }
    }
    
    func configureWith(index: Int) {
        viewModel.inputs.configure(index: index)
        indexLabel.text = viewModel.outputs.indexText
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if sender === likeButton {
            sender.isSelected = !sender.isSelected
            delegate?.sheetListCell(self, willChangeLikeStatus: sender.isSelected)
        } else {
            delegate?.sheetListCellWillOpenPopupMenu(self)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildUI()
    }
    
    private func buildUI() {
        selectionStyle = .none
        backgroundColor = .white
        isSkeletonable = true
        indexLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        playIv.snp.makeConstraints { (make) in
            make.center.equalTo(indexLabel)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        moreButton.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 18, height: 18))
        }
        likeButton.snp.makeConstraints { (make) in
            make.right.equalTo(moreButton.snp.left).offset(-20)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 15, height: 15))
        }
        nameLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(snp.centerY).offset(-3.5)
            make.left.equalTo(indexLabel.snp.right).offset(5)
            make.right.equalTo(likeButton.snp.left).offset(-15)
            make.height.equalTo(17)
        }
        artistLabel.snp.makeConstraints { (make) in
            make.width.equalTo(nameLabel).multipliedBy(0.75)
            make.top.equalTo(snp.centerY).offset(3.5)
            make.left.equalTo(nameLabel)
            make.height.equalTo(13)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
