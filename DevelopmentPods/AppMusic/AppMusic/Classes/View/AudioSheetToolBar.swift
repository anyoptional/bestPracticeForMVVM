//
//  AudioSheetTooBar.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import AudioService

protocol AudioSheetToolBarDataSource: class {
    /// 返回当前播放的音频
    func currentAudioForToolBar(_ toolBar: AudioSheetToolBar) -> MusicInfo?
    /// 返回当前播放状态
    func playStatusForToolBar(_ toolBar: AudioSheetToolBar) -> AudioStreamerPlayStatus
}

protocol AudioSheetToolBarDelegate: class {
    /// 将要改变播放状态
    func audioStreamerWillChangeState(_ isPlaying: Bool)
    /// 将要弹出音乐列表
    func audioStreamerWillShowAudioList()
    /// 将要打开播放器
    func audioStreamerWillOpenPlayerController()
}

class AudioSheetToolBar: UIControl {

    weak var delegate: AudioSheetToolBarDelegate?
    weak var dataSource: AudioSheetToolBarDataSource?
    
    private lazy var containerView: UIView = {
        let v = UIView()
        v.layer.shadowOffset = CGSize(width: 0.8, height: 0.8)
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.125
        v.layer.shadowRadius = 0.8
        v.layer.cornerRadius = 32
        v.backgroundColor = .white
        addSubview(v)
        return v
    }()
    
    private lazy var imgView: UIImageView = {
        let v = UIImageView()
        v.layer.cornerRadius = 30
        v.layer.masksToBounds = true
        v.contentMode = .scaleAspectFill
        v.isUserInteractionEnabled = true
        containerView.addSubview(v)
        return v
    }()

    private lazy var nameLabel: UILabel = {
        let v = UILabel()
        v.text = "暂无歌曲"
        v.textAlignment = .left
        v.textColor = GLarkdef.black_333345
        v.font = UIFont.systemFont(ofSize: 15)
        addSubview(v)
        return v
    }()
    
    private lazy var artistLabel: UILabel = {
        let v = UILabel()
        v.text = "暂无歌手"
        v.textAlignment = .left
        v.textColor = GLarkdef.gray_646580
        v.font = UIFont.systemFont(ofSize: 11)
        addSubview(v)
        return v
    }()
    
    private lazy var playButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(nameInBundle: "sheet_bottom_play"), for: .normal)
        v.setImage(UIImage(nameInBundle: "sheet_bottom_pause"), for: .selected)
        v.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        addSubview(v)
        return v
    }()
    
    private lazy var moreButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(nameInBundle: "sheet_show_list"), for: .normal)
        v.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        addSubview(v)
        return v
    }()
    
    private lazy var lineView: UIView = {
        let v = UIView()
        v.backgroundColor = GLarkdef.gray_EAEAEA
        addSubview(v)
        return v
    }()
    
    private lazy var viewModel: AudioSheetToolBarViewModelType = AudioSheetToolBarViewModel()

    func reloadData() {
        reloadAudio()
        reloadPlayStatus()
    }
    
    func reloadAudio() {
        let audio = dataSource?.currentAudioForToolBar(self)
        viewModel.inputs.configureWith(value: audio)
        nameLabel.text = viewModel.outputs.nameText
        artistLabel.text = viewModel.outputs.artistText
        imgView.fd.setImage(withURL: viewModel.outputs.audioCoverURL,
                            placeholder: UIImage(nameInBundle: "sheet_placeholder"))
    }
    
    func reloadPlayStatus() {
        let playStatus = dataSource?.playStatusForToolBar(self)
        playButton.isSelected = playStatus == .playing
    }
    
    @objc private func playButtonTapped() {
        playButton.isSelected = !playButton.isSelected
        delegate?.audioStreamerWillChangeState(playButton.isSelected)
    }
    
    @objc private func moreButtonTapped() {
        delegate?.audioStreamerWillShowAudioList()
    }
    
    @objc private func toolBarTapped() {
        delegate?.audioStreamerWillOpenPlayerController()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if containerView.frame.contains(point) ||
            imgView.frame.contains(point) ||
            nameLabel.frame.contains(point) ||
            artistLabel.frame.contains(point) {
            return self
        }
        return super.hitTest(point, with: event)
    }

    init() {
        super.init(frame: .zero)
        buildUI()
    }
    
    private func buildUI() {
        backgroundColor = GLarkdef.gray_FAFBFC
        addTarget(self, action: #selector(toolBarTapped), for: .touchUpInside)
        lineView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        containerView.snp.makeConstraints { (make) in
            make.left.equalTo(14)
            make.top.equalTo(-14)
            make.size.equalTo(CGSize(width: 64, height: 64))
        }
        imgView.snp.makeConstraints { (make) in
            make.left.equalTo(2)
            make.top.equalTo(2)
            make.size.equalTo(CGSize(width: 60, height: 60))
        }
        moreButton.snp.makeConstraints { (make) in
            make.right.equalTo(0)
            make.top.equalTo(0)
            make.size.equalTo(CGSize(width: 55, height: 55))
        }
        playButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(moreButton)
            make.right.equalTo(moreButton.snp.left)
            make.size.equalTo(CGSize(width: 55, height: 55))
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(containerView.snp.right).offset(10)
            make.right.equalTo(playButton.snp.left)
            make.top.equalTo(10)
        }
        artistLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.right.equalTo(nameLabel)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
