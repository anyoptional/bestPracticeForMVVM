//
//  AudioControlView.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import FOLDin
import AudioService

protocol AudioControlViewDataSource: class {
    /// 当前播放模式
    func playModeForStreamer() -> AudioStreamerPlayMode
    /// 当前播放状态
    func playStatusForStreamer() -> AudioStreamerPlayStatus
    /// 当前播放时长
    func currentPlayTimeForStreamer() -> Double
    /// 当前缓冲时长
    func bufferTimeForStreamer() -> Double
    /// 当前音频总时长
    func totalPlayTimeForStreamer() -> Double
    /// 当前音频是否被喜欢
    func audioLikeStatusForStreamer() -> Bool
}

protocol AudioControlViewDelegate: class {
    /// 将要播放上一曲
    func audioStreamerWillPlayPrev()
    /// 将要播放下一曲
    func audioStreamerWillPlayNext()
    /// 将要更新播放模式
    func audioStreamerWillChangePlayMode(_ newMode: AudioStreamerPlayMode)
    /// 将要更新播放状态
    func audioStreamerWillChangePlayStatus(_ isPlaying: Bool)
    /// 将要更新单曲喜欢状态
    func audioStreamerWillChangeLikeStatus(_ isLike: Bool)
    /// 将要显示列表
    func audioStreamerWillShowPlayList()
    /// 将要删除当前曲目
    func audioStreamerWillDeleteAudio()
    /// 将要快进快退
    func audioStreamerWillSeekToTime(_ newTime: Double)
}

class AudioControlView: UIView {

    private lazy var modeButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(nameInBundle: "control_sequence_loop"), for: .normal)
        addSubview(v)
        return v
    }()
    
    private lazy var prevButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(nameInBundle: "control_prev"), for: .normal)
        addSubview(v)
        return v
    }()
    
    private lazy var playButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(nameInBundle: "control_play"), for: .normal)
        v.setImage(UIImage(nameInBundle: "control_pause"), for: .selected)
        addSubview(v)
        return v
    }()
    
    private lazy var nextButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(nameInBundle: "control_next"), for: .normal)
        addSubview(v)
        return v
    }()
    
    private lazy var listButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(nameInBundle: "control_show_list"), for: .normal)
        addSubview(v)
        return v
    }()
    
    private(set) lazy var topView: UIView = {
        let v = UIView()
        addSubview(v)
        return v
    }()
    
    private lazy var likeButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(nameInBundle: "control_unlike"), for: .normal)
        v.setImage(UIImage(nameInBundle: "control_like"), for: .selected)
        topView.addSubview(v)
        return v
    }()
    
    private lazy var deleteButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(nameInBundle: "control_delete"), for: .normal)
        topView.addSubview(v)
        return v
    }()
    
    private lazy var curTimeLabel: UILabel = {
        let v = UILabel()
        v.textAlignment = .left
        v.textColor = .white
        v.font = UIFont.systemFont(ofSize: 11)
        addSubview(v)
        return v
    }()
    
    private lazy var durationLabel: UILabel = {
        let v = UILabel()
        v.textAlignment = .right
        v.textColor = .white
        v.font = UIFont.systemFont(ofSize: 11)
        addSubview(v)
        return v
    }()
    
    private lazy var progressBar: FDProgressBar = {
        let bar = FDProgressBar()
        bar.delegate = self
        bar.isAllowsTap = true
        bar.isContinuous = false
        bar.minimumTrackTintColor = .white
        bar.thumbImage = UIImage(nameInBundle: "control_thumb")
        bar.bufferTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        bar.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.2)
        addSubview(bar)
        return bar
    }()
    
    weak var delegate: AudioControlViewDelegate?
    weak var dataSource: AudioControlViewDataSource? {
        didSet {
            reloadData()
        }
    }
    
    func reloadData() {
        reloadPlayMode()
        reloadTotalTime()
        reloadPlayStatus()
        reloadLikeStatus()
        reloadBufferTime()
        reloadCurrentTime()
    }
    
    func reloadPlayMode() {
        switch dataSource?.playModeForStreamer() ?? .sequenceLoop {
        case .sequenceLoop:
            modeButton.setImage(UIImage(nameInBundle: "control_sequence_loop"), for: .normal)
        case .singleLoop:
            modeButton.setImage(UIImage(nameInBundle: "control_single_loop"), for: .normal)
        case .random:
            modeButton.setImage(UIImage(nameInBundle: "control_random"), for: .normal)
        }
    }
    
    func reloadPlayStatus() {
        let playStatus = (dataSource?.playStatusForStreamer() ?? .stop)
        progressBar.isBuffering = playStatus == .buffering
        playButton.isSelected = playStatus == .playing
    }
    
    func reloadLikeStatus() {
        likeButton.isSelected = dataSource?.audioLikeStatusForStreamer() ?? false
    }
    
    func reloadCurrentTime() {
        guard let curTime = dataSource?.currentPlayTimeForStreamer() else { return }
        let min = Int(curTime / 60)
        let sec = Int(curTime.truncatingRemainder(dividingBy: 60))
        curTimeLabel.text = String(format: "%02d:%02d", min, sec)
    }
    
    func reloadTotalTime() {
        guard let duration = dataSource?.totalPlayTimeForStreamer() else { return }
        let min = Int(duration / 60)
        let sec = Int(duration.truncatingRemainder(dividingBy: 60))
        durationLabel.text = String(format: "%02d:%02d", min, sec)
    }
    
    func reloadProgress() {
        guard let curTime = dataSource?.currentPlayTimeForStreamer(),
            let duration = dataSource?.totalPlayTimeForStreamer() else { return }
        let progress = curTime / duration
        if !progressBar.isDragging {
            progressBar.value = progress
        }
    }
    
    func reloadBufferTime() {
        guard let bufTime = dataSource?.bufferTimeForStreamer(),
            let duration = dataSource?.totalPlayTimeForStreamer() else { return }
        let progress = bufTime / duration
        progressBar.bufferValue = progress
    }
    
    @objc private func buttonTapped(_ button: UIButton) {
        if button === prevButton {
            delegate?.audioStreamerWillPlayPrev()
        } else if button === nextButton {
            delegate?.audioStreamerWillPlayNext()
        } else if button === modeButton {
            let oldMode = dataSource?.playModeForStreamer() ?? .sequenceLoop
            delegate?.audioStreamerWillChangePlayMode(oldMode.next)
        } else if button === playButton {
            button.isSelected = !button.isSelected
            delegate?.audioStreamerWillChangePlayStatus(button.isSelected)
        } else if button === listButton {
            delegate?.audioStreamerWillShowPlayList()
        } else if button === likeButton {
            button.isSelected = !button.isSelected
            delegate?.audioStreamerWillChangeLikeStatus(button.isSelected)
        } else if button === deleteButton {
            delegate?.audioStreamerWillDeleteAudio()
        }
    }
    
    init() {
        super.init(frame: .zero)
        buildUI()
    }
    
    private func buildUI() {
        let buttons = [modeButton, prevButton, playButton, nextButton, listButton]
        buttons.snp.distributeViewsAlong(axisType: .horizontal,
                                         fixedItemLength: 50,
                                         leadSpacing: 20,
                                         tailSpacing: 20)
        buttons.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-40)
            } else {
                make.bottom.equalTo(-40)
            }
            make.height.equalTo(50)
        }
        buttons.forEach {
            $0.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
        likeButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

        curTimeLabel.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.left.equalTo(10)
            make.bottom.equalTo(playButton.snp.top).offset(-24)
        }
        durationLabel.snp.makeConstraints { (make) in
            make.centerY.width.equalTo(curTimeLabel)
            make.right.equalTo(-10)
        }
        progressBar.snp.makeConstraints { (make) in
            make.left.equalTo(curTimeLabel.snp.right)
            make.right.equalTo(durationLabel.snp.left)
            make.centerY.equalTo(curTimeLabel)
            make.height.equalTo(20)
        }
        topView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        likeButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 23, height: 23))
            make.centerY.equalToSuperview()
            make.right.equalTo(topView.snp.centerX).offset(-30)
        }
        deleteButton.snp.makeConstraints { (make) in
            make.size.centerY.equalTo(likeButton)
            make.left.equalTo(topView.snp.centerX).offset(30)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AudioControlView: FDProgressBarDelegate {
    func progressBar(_ progressBar: FDProgressBar, valueChanged newValue: Double) {
        guard let duration = dataSource?.totalPlayTimeForStreamer() else { return }
        delegate?.audioStreamerWillSeekToTime(duration * newValue)
    }
}
