//
//  AudioPlateView.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import YYKit
import AudioService

protocol AudioPlateViewDataSource: class {
    /// 当前播放列表
    func audioPlayListForStreamer(_ plateView: AudioPlateView) -> [MusicInfo]
    /// 当前播放歌曲在列表中的位置
    func indexForCurrentAudioInPlayList(_ plateView: AudioPlateView) -> Int
}

protocol AudioPlateViewDelegate: class {
    /// 将要拖动圆盘
    func plateViewWillBeginDragging(_ plateView: AudioPlateView)
    /// 当前音频已经切换
    func audioStreamerPlayIndexWillChange(_ curIndex: Int, _ curAudio: MusicInfo)
    /// 将要显示歌词界面
    func plateViewDidTapped(_ plateView: AudioPlateView)
}

class AudioPlateView: UIView {

    private lazy var leftItemView = AudioPlateItemView()
    private lazy var midItemView = AudioPlateItemView()
    private lazy var rightItemView = AudioPlateItemView()
    
    private lazy var backgroundLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.black.withAlphaComponent(0.2).cgColor
        layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        layer.borderWidth = 10
        layer.masksToBounds = true
        return layer
    }()
    
    private(set) lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.delegate = self
        v.isPagingEnabled = true
        v.showsHorizontalScrollIndicator = false
        v.contentSize = CGSize(width: kScreenWidth * 3, height: 0)
        v.setContentOffset(CGPoint(x: kScreenWidth, y: 0), animated: false)
        return v
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundLayer.top = 66
        backgroundLayer.width = width - 80
        backgroundLayer.height = backgroundLayer.width
        backgroundLayer.centerX = width / 2
        backgroundLayer.cornerRadius = backgroundLayer.width / 2
        
        scrollView.frame = bounds

        leftItemView.left = 0
        leftItemView.top = 0
        leftItemView.width = scrollView.width
        leftItemView.height = scrollView.height
        
        midItemView.left = leftItemView.right
        midItemView.top = leftItemView.top
        midItemView.size = leftItemView.size
        
        rightItemView.left = midItemView.right
        rightItemView.top = midItemView.top
        rightItemView.size = midItemView.size
    }
    
    weak var delegate: AudioPlateViewDelegate?
    weak var dataSource: AudioPlateViewDataSource? {
        didSet {
            reloadData()
        }
    }
    
    private lazy var timer: CADisplayLink? = nil
    
    init() {
        super.init(frame: .zero)
        buildUI()
    }
    
    private func buildUI() {
        layer.addSublayer(backgroundLayer)
        addSubview(scrollView)
        scrollView.addSubview(leftItemView)
        scrollView.addSubview(midItemView)
        scrollView.addSubview(rightItemView)
        addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                    action: #selector(plateViewTapped)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopAnimating()
        gestureRecognizers?.forEach {
            removeGestureRecognizer($0)
        }
    }
}

extension AudioPlateView {
    /// 重置
    func reloadData() {
        scrollViewDidEndScrolling(scrollView)
    }
    
    func startAnimating() {
        if timer == nil {
            timer = CADisplayLink(target: YYWeakProxy(target: self),
                                  selector: #selector(rotationPlateItem))
            timer?.add(to: RunLoop.main, forMode: .common)
        }
    }
    
    func stopAnimating() {
        timer?.remove(from: RunLoop.main, forMode: .common)
        timer?.invalidate()
        timer = nil
    }
}

extension AudioPlateView {
    @objc private func plateViewTapped() {
        delegate?.plateViewDidTapped(self)
    }
    
    @objc private func rotationPlateItem() {
        midItemView.imgView.transform = midItemView.imgView.transform.rotated(by: CGFloat.pi / 4 / 150)
    }
    
    private func scrollsWithoutAnimation() {
        if scrollView.contentOffset.x != kScreenWidth {
            scrollView.setContentOffset(CGPoint(x: kScreenWidth, y: 0), animated: false)
        }
    }
    
    private func scrollViewDidEndScrolling(_ scrollView: UIScrollView) {
        guard let dataSource = dataSource else { return }
        let offsetX = scrollView.contentOffset.x
        let curIndex = dataSource.indexForCurrentAudioInPlayList(self)
        let audioList = dataSource.audioPlayListForStreamer(self)
        guard !audioList.isEmpty else { return }
        var nextIndex = curIndex
        if offsetX == 2 * kScreenWidth {
            nextIndex = (curIndex + 1) % audioList.count
        } else if offsetX == 0 {
            nextIndex = (curIndex - 1 + audioList.count) % audioList.count
        }
        if curIndex != nextIndex {
            nextIndexCaculated(nextIndex, audioList)
        } else {
            let placeholder = UIImage(nameInBundle: "cm2_default_cover_fm")
            let midURL = URL(string: audioList[curIndex].picUrl.filterNil())
            midItemView.imgView.fd.setImage(withURL: midURL, placeholder: placeholder)
            delegate?.audioStreamerPlayIndexWillChange(curIndex, audioList[curIndex])
        }
    }
    
    private func nextIndexCaculated(_ nextIndex: Int, _ audioList: [MusicInfo]) {
        let count = audioList.count
        let nextAudio = audioList[nextIndex]
        let placeholder = UIImage(nameInBundle: "cm2_default_cover_fm")
        let midURL = URL(string: nextAudio.picUrl.filterNil())
        midItemView.imgView.fd.setImage(withURL: midURL, placeholder: placeholder)
        midItemView.imgView.transform = .identity
        self.scrollsWithoutAnimation()
        let leftIndex = (nextIndex + count - 1) % count;
        let leftURL = URL(string: audioList[leftIndex].picUrl.filterNil())
        self.leftItemView.imgView.fd.setImage(withURL: leftURL, placeholder: placeholder)
        let rightIndex = (nextIndex + 1) % count
        let rightURL = URL(string: audioList[rightIndex].picUrl.filterNil())
        self.rightItemView.imgView.fd.setImage(withURL: rightURL, placeholder: placeholder)
        self.delegate?.audioStreamerPlayIndexWillChange(nextIndex, nextAudio)
    }
}

extension AudioPlateView: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.plateViewWillBeginDragging(self)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrolling(scrollView)
    }
}

fileprivate class AudioPlateItemView: UIView {
    
    fileprivate lazy var plateIv: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(nameInBundle: "cm2_play_disc")
        v.contentMode = .scaleAspectFit
        v.clipsToBounds = true
        addSubview(v)
        return v
    }()
    
    fileprivate lazy var imgView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(nameInBundle: "cm2_default_cover_fm")
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        plateIv.addSubview(v)
        return v
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        plateIv.width = kScreenWidth - 80
        plateIv.height = plateIv.width
        plateIv.top = 66
        plateIv.centerX = width / 2
        
        imgView.width = plateIv.width - 100
        imgView.height = plateIv.height - 100
        imgView.centerX = plateIv.width / 2
        imgView.centerY = plateIv.height / 2
        imgView.layer.cornerRadius = imgView.width / 2
    }
}
