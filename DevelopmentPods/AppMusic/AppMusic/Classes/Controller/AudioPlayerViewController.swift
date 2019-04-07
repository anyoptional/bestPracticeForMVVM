//
//  AudioPlayerViewController.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import Fatal
import YYKit
import FOLDin
import RxSwift
import SwiftyHUD
import AudioService

class AudioPlayerViewController: UIViewController {

    override var prefersNavigationBarStyle: UINavigationBarStyle {
        return .custom
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // 歌词
    private lazy var lyricView = AudioLyricView()
    // 圆盘
    private lazy var plateView = AudioPlateView()
    // 音乐控制
    private lazy var controlView = AudioControlView()

    private lazy var streamer = AudioStreamerBuilder().build()
    
    private lazy var lyricItems: [AudioLyricItemProtocol]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        buildNavbar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        conflictFixup()
        prepareStreamer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cleanStreamer()
    }
    
    deinit {
        NSLog("%@ is deallocating...", className())
    }
}

extension AudioPlayerViewController {
    /// 切换到播放状态
    private func prepareStreamer() {
        streamer.delegate = self
        if !streamer.isPlaying {
            streamer.resume()
        }
        // 状态同步
        reloadNavigation()
        reloadBackground()
        reloadLyricItems()
        plateView.startAnimating()
        controlView.reloadLikeStatus()
        controlView.reloadBufferTime()
    }
    
    /// 避免强引用
    private func cleanStreamer() {
        streamer.delegate = nil
    }
    
    /// 解决手势冲突
    private func conflictFixup() {
        if let gesture = navigationController?.interactivePopGestureRecognizer {
            plateView.scrollView.panGestureRecognizer.require(toFail: gesture)
        }
    }
}

extension AudioPlayerViewController: AudioPlateViewDelegate {
    func plateViewWillBeginDragging(_ plateView: AudioPlateView) {
        plateView.stopAnimating()
    }
    
    func audioStreamerPlayIndexWillChange(_ curIndex: Int, _ curAudio: MusicInfo) {
        guard let oldIndex = streamer.currentIndex else { return }
        // 已经变了
        // 动画由streamer回调控制
        if oldIndex != curIndex {
            streamer.play(at: curIndex)
        } else {
            // 没变 看一下是否需要继续动画
            if streamer.isPlaying {
                plateView.startAnimating()
            }
        }
    }
    
    func plateViewDidTapped(_ plateView: AudioPlateView) {
        lyricView.alpha = 0
        lyricView.isHidden = false
        controlView.topView.alpha = 1
        UIView.animate(withDuration: 0.5, animations: {
            self.lyricView.alpha = 1
            self.plateView.alpha = 0
            self.controlView.topView.alpha = 0
        }, completion: { (flag) in
            self.plateView.isHidden = true
        })
    }
}

extension AudioPlayerViewController: AudioPlateViewDataSource {
    func audioPlayListForStreamer(_ plateView: AudioPlateView) -> [MusicInfo] {
        return streamer.currentAudioList ?? []
    }
    
    func indexForCurrentAudioInPlayList(_ plateView: AudioPlateView) -> Int {
        return streamer.currentIndex ?? 0
    }
}

extension AudioPlayerViewController: AudioLyricViewDataSource {
    func lyricItemsForLyricView(_ lyricView: AudioLyricView) -> [AudioLyricItemProtocol]? {
        return lyricItems
    }
    
    func currentLyricItemIndexForLyricView(_ lyricView: AudioLyricView) -> Int? {
        guard let lyricItems = lyricItems else { return nil }
        // 找到在前一句和后一句之间的
        for index in lyricItems.indices {
            let curItem = lyricItems[index]
            var nextItem: AudioLyricItemProtocol? = nil
            if index < lyricItems.count - 1 {
                nextItem = lyricItems[index + 1]
            }
            if (streamer.currentTime > curItem.seconds)
                && (nextItem == nil || streamer.currentTime < nextItem!.seconds) {
                return index
            }
        }
        return nil
    }
}

extension AudioPlayerViewController: AudioLyricViewDelegate {
    func lyricViewDidTapped(_ lyricView: AudioLyricView) {
        plateView.alpha = 0
        plateView.isHidden = false
        controlView.topView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.lyricView.alpha = 0
            self.plateView.alpha = 1
            self.controlView.topView.alpha = 1
        }, completion: { (flag) in
            self.lyricView.isHidden = true
        })
    }
}

extension AudioPlayerViewController: AudioStreamerDelegate {
    func audioStramerPlayStatusDidChange(_ newStatus: AudioStreamerPlayStatus) {
        controlView.reloadPlayStatus()
        if newStatus == .playing {
            plateView.startAnimating()
        } else {
            plateView.stopAnimating()
        }
    }
    
    func audioStreamerPlayModeDidChange(_ newMode: AudioStreamerPlayMode) {
        controlView.reloadPlayMode()
        SwiftyHUD.show(message: newMode.description, duration: 2, bezelAlpha: 0.4)
    }
    
    func audioStreamerCurrentTimeDidChange(_ currentTime: Double) {
        lyricView.reloadCurrentItem()
        controlView.reloadProgress()
        controlView.reloadTotalTime()
        controlView.reloadCurrentTime()
    }
    
    func audioStreamerBufferedTimeDidChange(_ bufferedTime: Double) {
        controlView.reloadBufferTime()
    }
    
    func audioStreamerCurrentAudioDidChange(_ newAudio: MusicInfo) {
        reloadNavigation()
        reloadBackground()
        reloadLyricItems()
        plateView.reloadData()
        controlView.reloadData()
    }
    
    func audioStreamerDidFinishWithError(_ error: ErrorConvertible) {
        SwiftyHUD.show(message: error.message, bezelAlpha: 0.4)
    }
}

extension AudioPlayerViewController: AudioControlViewDelegate {
    func audioStreamerWillPlayPrev() {
        streamer.playPrev()
    }
    
    func audioStreamerWillPlayNext() {
        streamer.playNext()
    }
    
    func audioStreamerWillChangePlayMode(_ newMode: AudioStreamerPlayMode) {
        streamer.playMode = newMode
        controlView.reloadPlayMode()
    }
    
    func audioStreamerWillChangePlayStatus(_ isPlaying: Bool) {
        if isPlaying {
            streamer.resume()
            plateView.startAnimating()
        } else {
            streamer.pause()
            plateView.stopAnimating()
        }
        controlView.reloadPlayStatus()
    }
    
    func audioStreamerWillChangeLikeStatus(_ isLike: Bool) {
        guard let audio = streamer.currentAudio else { return }
        Observable.just(isLike)
            .flatMap { (isLike) -> Observable<Void> in
                // 之前没有喜欢
                if isLike {
                    return AudioProvider.addAudioCollection(by: [audio.musicId.filterNil()])
                }
                return AudioProvider.cancelAudioCollection(by: [audio.musicId.filterNil()])
            }.subscribe(onNext: { _ in
                audio.isCollection = isLike
            }, onError: { (error) in
                self.controlView.reloadLikeStatus()
                if let error = error as? ErrorConvertible {
                    SwiftyHUD.show(message: error.message, bezelAlpha: 0.4)
                }
            }).disposed(by: disposeBag)
    }
    
    func audioStreamerWillShowPlayList() {
        let listView = AudioPopupView()
        listView.delegate = self
        listView.dataSource = self
        listView.width = view.width
        listView.height = view.height * 0.667
        FDPopupViewBuilder()
            .setSourceView(view)
            .setContentView(listView)
            .setPresentationStyle(.bottom)
            .setPresentationAnimation(.fromBottom)
            .setDismissalAimation(.fromBottom)
            .setStyle(.translucent(alpha: 0.4))
            .build().popup()
    }
    
    func audioStreamerWillSeekToTime(_ newTime: Double) {
        streamer.seek(to: newTime)
    }
    
    func audioStreamerWillDeleteAudio() {
        guard let audio = streamer.currentAudio else { return }
        streamer.removeAudioList([audio])
        if streamer.isAudioListEmpty {
            navigationController?.popViewController(animated: true)
        }
    }
}

extension AudioPlayerViewController: AudioPopupViewDelegate, AudioPopupViewDataSource {
    func popupView(_ popupView: AudioPopupView, didSelectAudioAtIndex index: Int) {
        streamer.play(at: index)
    }
    
    func popupViewWillRemoveAudio(at index: Int) {
        guard let audioList = streamer.currentAudioList else {
            return
        }
        streamer.removeAudioList([audioList[index]])
        if streamer.isAudioListEmpty {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func popupViewWillChangePlayMode(_ popupView: AudioPopupView) {
        let playMode = streamer.playMode
        streamer.playMode = playMode.next
        controlView.reloadPlayMode()
    }
    
    func popupViewWillClearPlayList(_ popupView: AudioPopupView) {
        guard let audioList = streamer.currentAudioList else {
            SwiftyHUD.show(message: "你还没有选歌")
            return
        }
        self.streamer.removeAudioList(audioList)
        navigationController?.popViewController(animated: true)
    }
    
    func playModeForPopupView(_ popupView: AudioPopupView) -> AudioStreamerPlayMode {
        return streamer.playMode
    }
    
    func playListForPopupView(_ popupView: AudioPopupView) -> [MusicInfo]? {
        return streamer.currentAudioList
    }
    
    func currentPlayIndexForPopupView(_ popupView: AudioPopupView) -> Int? {
        return streamer.currentIndex
    }
    
    func aduioStreamerDidClearPlayList() {
        navigationController?.popViewController(animated: true)
    }
}

extension AudioPlayerViewController: AudioControlViewDataSource {
    func playModeForStreamer() -> AudioStreamerPlayMode {
        return streamer.playMode
    }
    
    func playStatusForStreamer() -> AudioStreamerPlayStatus {
        return streamer.playStatus
    }
    
    func bufferTimeForStreamer() -> Double {
        return streamer.bufferedTime
    }
    
    func currentPlayTimeForStreamer() -> Double {
        return streamer.currentTime
    }
    
    func totalPlayTimeForStreamer() -> Double {
        return streamer.duration
    }
    
    func audioLikeStatusForStreamer() -> Bool {
        return streamer.currentAudio?.isCollection ?? false
    }
}

extension AudioPlayerViewController {
    /// 加载歌词
    private func reloadLyricItems() {
        let urlString = streamer.currentAudio?.lrcUrl
        let lyricURL = URL(string: urlString.filterNil())
        AudioLyricParserBuilder()
            .setLyricURL(lyricURL)
            .build()
            .parse()
            .subscribeNext(weak: self) { (self) in
                return { (lyricItems) in
                    self.lyricItems = lyricItems
                    self.lyricView.reloadData()
                }
            }.disposed(by: disposeBag)
    }
}

extension AudioPlayerViewController {
    /// 刷新导航条
    private func reloadNavigation() {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .white
        let curAudio = streamer.currentAudio
        let prefix = (curAudio?.musicName).filterNil()
        let suffix = (curAudio?.singerName).filterNil()
        let fullText = prefix + "\n" + suffix
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.alignment = .center
        let attrText = NSMutableAttributedString(string: fullText, attributes: [.paragraphStyle : paragraphStyle,
                                                                                .font : UIFont.systemFont(ofSize: 13)])
        attrText.addAttributes([.font : UIFont.systemFont(ofSize: 11)], range: (fullText as NSString).range(of: suffix))
        titleLabel.attributedText = attrText
        titleLabel.sizeToFit()
        fd.navigationItem.titleView = titleLabel
    }
    
    /// 刷新背景图（平滑过度）
    private func reloadBackground() {
        let placeholder = UIImage(nameInBundle: "cm2_fm_bg.jpg")
        // 第一次没有背景 用内置的
        if view.layer.contents == nil {
            view.layer.contents = placeholder?.cgImage
        }
        // 之后如果加载过图片，用之前加载的当占位图
        let cgImage = view.layer.contents as! CGImage // safe
        let url = URL(string: (streamer.currentAudio?.picUrl).filterNil())
        view.layer.setImageWith(url, placeholder: UIImage(cgImage: cgImage), options: [.avoidSetImage])
        { [weak self] (image, _, _, _, _) in
            guard let `self` = self else { return }
            if let image = image {
                self.view.layer.removeAnimation(forKey: "_KFadeAnimationKey")
                DispatchQueue.main.asyncAfter(deadline: 0.5, execute: {
                    let transition = CATransition()
                    transition.type = .fade
                    transition.duration = 0.3
                    transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    self.view.layer.add(transition, forKey: "_KFadeAnimationKey")
                    self.view.layer.contents = image.byBlurRadius(40,
                                                     tintColor: UIColor(white: 0.5, alpha: 0.5),
                                                     tintMode: .normal, saturation: 1.8, maskImage: nil)?.cgImage
                })
            }
        }
    }
}

extension AudioPlayerViewController {
    /// 返回上一级
    @objc private func popViewControllerAnimated() {
        navigationController?.popViewController(animated: true)
    }
}

extension AudioPlayerViewController {
    private func buildNavbar() {
        fd.navigationBar.barTintColor = .clear
        fd.navigationBar.contentMargin.left = 5
        let backButton = UIButton()
        let image = UIImage(nameInBundle: "nav_back_white")?
            .byResize(to: CGSize(width: 30, height: 30), contentMode: .center)
        backButton.setImage(image, for: .normal)
        backButton.size = CGSize(width: 30, height: 30)
        backButton.addTarget(self, action: #selector(popViewControllerAnimated), for: .touchUpInside)
        fd.navigationItem.leftBarButtonItem = FDBarButtonItem(customView: backButton)
    }
    
    private func buildUI() {
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.contentsGravity = .resizeAspectFill
        
        controlView.delegate = self
        controlView.dataSource = self
        view.addSubview(controlView)
        controlView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
            make.left.right.equalToSuperview()
            make.height.equalTo(200)
        }
        
        plateView.delegate = self
        plateView.dataSource = self
        view.addSubview(plateView)
        plateView.snp.makeConstraints { (make) in
            make.top.equalTo(fd.navigationBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(controlView.snp.top)
        }
        
        lyricView.isHidden = true
        lyricView.delegate = self
        lyricView.dataSource = self
        view.addSubview(lyricView)
        lyricView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(plateView)
            make.bottom.equalTo(controlView.snp.top).offset(50)
        }
        
        view.bringSubviewToFront(controlView)
    }
}
