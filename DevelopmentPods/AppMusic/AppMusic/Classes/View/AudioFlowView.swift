//
//  AudioFlowView.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import AudioService

protocol AudioFlowViewDelegate: class {
    /// 将要改变播放状态
    func audioFlowView(_ flowView: AudioFlowView, willChangePlayStatus isPlaying: Bool)
    /// 将要打开播放器
    func audioFlowViewWillOpenPlayerController(_ flowView: AudioFlowView)
    /// 将要关闭
//    func audioFlowViewWillClose(_ flowView: AudioFlowView)
}

protocol AudioFlowViewDataSource: class {
    /// 返回当前播放的音频
    func currentAudioForFlowView(_ flowView: AudioFlowView) -> MusicInfo?
    /// 返回当前播放状态
    func playStatusForFlowView(_ flowView: AudioFlowView) -> AudioStreamerPlayStatus
}

class AudioFlowView: UIControl {
    
    weak var delegate: AudioFlowViewDelegate?
    weak var dataSource: AudioFlowViewDataSource?
    
//    private lazy var exitButton: UIButton = {
//        let v = UIButton()
//        v.setImage(UIImage(nameInBundle: "flow_close"), for: .normal)
//        v.addTarget(self, action: #selector(dismissal), for: .touchUpInside)
//        addSubview(v)
//        return v
//    }()
    
    private lazy var imgView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(nameInBundle: "sheet_placeholder")
        v.contentMode = .scaleAspectFill
        addSubview(v)
        return v
    }()
    
    private lazy var nameLabel: UILabel = {
        let v = UILabel()
        v.text = "暂无歌曲"
        v.textColor = .white
        v.textAlignment = .left
        v.font = UIFont.systemFont(ofSize: 12)
        addSubview(v)
        return v
    }()
    
    private lazy var artistLabel: UILabel = {
        let v = UILabel()
        v.text = "暂无歌手"
        v.textColor = .white
        v.textAlignment = .left
        v.font = UIFont.systemFont(ofSize: 12)
        addSubview(v)
        return v
    }()
    
    private lazy var playButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(nameInBundle: "flow_play"), for: .normal)
        v.setImage(UIImage(nameInBundle: "flow_pause"), for: .selected)
        v.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        addSubview(v)
        return v
    }()
    
    private lazy var viewModel: AudioFlowViewModelType = AudioFlowViewModel()
    
    func reloadData() {
        reloadAudio()
        reloadPlayStatus()
    }
    
    func reloadAudio() {
        let audio = dataSource?.currentAudioForFlowView(self)
        viewModel.inputs.configureWith(value: audio)
        nameLabel.text = viewModel.outputs.nameText
        artistLabel.text = viewModel.outputs.artistText
        imgView.fd.setImage(withURL: viewModel.outputs.audioCoverURL,
                            placeholder: UIImage(nameInBundle: "sheet_placeholder"))
    }
    
    func reloadPlayStatus() {
        let playStatus = dataSource?.playStatusForFlowView(self)
        playButton.isSelected = playStatus == .playing
    }
    
//    @objc private func dismissal() {
//        delegate?.audioFlowViewWillClose(self)
//    }
    
    @objc private func playButtonTapped() {
        playButton.isSelected = !playButton.isSelected
        delegate?.audioFlowView(self, willChangePlayStatus: playButton.isSelected)
    }
    
    @objc private func flowViewTapped() {
        delegate?.audioFlowViewWillOpenPlayerController(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = height / 2
        layer.masksToBounds = true
        imgView.layer.cornerRadius = imgView.height / 2
        imgView.layer.masksToBounds = true
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = GLarkdef.gray_646580
        addTarget(self, action: #selector(flowViewTapped), for: .touchUpInside)
//        exitButton.snp.makeConstraints { (make) in
//            make.left.centerY.equalToSuperview()
//            make.size.equalTo(CGSize(width: 37, height: 37))
//        }
        imgView.snp.makeConstraints { (make) in
//            make.left.equalTo(exitButton.snp.right)
            make.left.equalTo(10)
            make.top.equalTo(1)
            make.bottom.equalTo(-1)
            make.width.equalTo(imgView.snp.height)
        }
        playButton.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.top.equalTo(6.5)
            make.bottom.equalTo(-6.5)
            make.width.equalTo(playButton.snp.height)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imgView.snp.right).offset(8)
            make.bottom.equalTo(imgView.snp.centerY).offset(-2)
            make.right.equalTo(playButton.snp.left).offset(-20)
        }
        artistLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(nameLabel)
            make.top.equalTo(imgView.snp.centerY).offset(2)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
