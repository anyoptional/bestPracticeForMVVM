//
//  AudioStreamer.swift
//  AudioService
//
//  Created by Archer on 2019/2/25.
//

import Fatal

/// 播放状态
public enum AudioStreamerPlayStatus {
    /// 缓冲中
    case buffering
    /// 正在播放
    case playing
    /// 已暂停
    case pause
    /// 已结束
    case stop
}

/// 播放模式
public enum AudioStreamerPlayMode: CustomStringConvertible {
    /// 列表循环
    case sequenceLoop
    /// 单曲循环
    case singleLoop
    /// 随机
    case random
    
    /// 下一播放状态
    public var next: AudioStreamerPlayMode {
        switch self {
        case .sequenceLoop: return .singleLoop
        case .singleLoop: return .random
        case .random: return .sequenceLoop
        }
    }
    
    /// 模式的描述
    public var description: String {
        switch self {
        case .sequenceLoop: return "列表循环"
        case .singleLoop: return "单曲循环"
        case .random: return "随机播放"
        }
    }
}

/// 播放代理
public protocol AudioStreamerDelegate: class {
    /// 播放器状态变更回调
    func audioStramerPlayStatusDidChange(_ newStatus: AudioStreamerPlayStatus)
    
    /// 播放器播放模式变更回调
    func audioStreamerPlayModeDidChange(_ newMode: AudioStreamerPlayMode)
    
    /// 播放器当前时间变更回调
    func audioStreamerCurrentTimeDidChange(_ currentTime: Double)
    
    /// 播放器缓冲时长变更回调
    func audioStreamerBufferedTimeDidChange(_ bufferedTime: Double)
    
    /// 播放器当前音乐变更回调
    func audioStreamerCurrentAudioDidChange(_ newAudio: MusicInfo)
    
    /// 播放器加载失败回调
    func audioStreamerDidFinishWithError(_ error: ErrorConvertible)
}

/// 代表一个播放器
public protocol AudioStreamerProtocol {
    /// 播放代理
    var delegate: AudioStreamerDelegate? { get set }
    
    /// 从audioList的index处开始播放
    func playAtIndex(_ index: Int, audioList: [MusicInfo])
    
    /// 播放模式
    var playMode: AudioStreamerPlayMode { get set }
    
    /// 当前播放状态
    var playStatus: AudioStreamerPlayStatus { get }
    
    /// 当前播放列表
    var currentAudioList: [MusicInfo]? { get }
    
    /// 当前播放歌曲
    var currentAudio: MusicInfo? { get }
    
    /// 当前歌曲总时长
    var duration: Double { get }
    
    /// 当前播放的时长
    var currentTime: Double { get }
    
    /// 当前缓冲时长
    var bufferedTime: Double { get }
    
    /// 暂停
    func pause()
    
    /// 恢复
    func resume()
    
    /// 停止
    func stop()
    
    /// 播放下一曲
    func playNext()
    
    /// 播放上一曲
    func playPrev()
    
    /// 快进快退
    func seek(to time: Double)
    
    /// 添加新的歌曲到列表
    func appendAudioList(_ newList: [MusicInfo])
    
    /// 从播放列表删除歌曲
    func removeAudioList(_ listToRemove: [MusicInfo])
    
    /// 修改当前音频音量大小(0~1)
    func setVolume(_ newVolume: Double)
}

extension AudioStreamerProtocol {
    /// Default implementation for `isPlaying` property
    public var isPlaying: Bool {
        return playStatus == .playing
    }
    
    /// Is currentAudioList empty or not
    public var isAudioListEmpty: Bool {
        guard let currentAudioList = currentAudioList else {
            return true
        }
        return currentAudioList.isEmpty
    }
    
    /// CurrentAudio's index at currentAudioList
    public var currentIndex: Int? {
        guard let audio = currentAudio else { return nil }
        return currentAudioList?.firstIndex(where: { audio.isEqual($0) })
    }
    
    /// Plays a aduio that at `index` in current play list
    public func play(at index: Int) {
        guard let audioList = currentAudioList else { return }
        playAtIndex(index, audioList: audioList)
    }
    
    /// Plays the input audio, note that this audio should in current play list
    public func play(audio: MusicInfo) {
        guard let audioList = currentAudioList else { return }
        guard let index = audioList.firstIndex(where: { audio.isEqual($0) }) else { return }
        playAtIndex(index, audioList: audioList)
    }
}

public class AudioStreamerBuilder {
    
    fileprivate var delegate: AudioStreamerDelegate?
    
    public init() {}
    
    public func setDelegate(_ delegate: AudioStreamerDelegate) -> AudioStreamerBuilder {
        self.delegate = delegate
        return self
    }
    
    public func build() -> AudioStreamerProtocol {
        let streamer = AudioStreamer.shared
        streamer.delegate = delegate
        return streamer
    }
}

/// 音乐包装类
fileprivate class AudioStreamer: NSObject, AudioStreamerProtocol {
    
    // underlying player instance
    fileprivate let player = AudioPlayer()
    
    fileprivate weak var delegate: AudioStreamerDelegate?
    
    fileprivate static let shared = AudioStreamer()
    
    fileprivate override init() {
        super.init()
        player.delegate = self
    }
    
    fileprivate func playAtIndex(_ index: Int, audioList: [MusicInfo]) {
        player.play(items: audioList, startAtIndex: index)
    }
    
    fileprivate var playMode: AudioStreamerPlayMode {
        set {
            player.mode = newValue.toAudioPlayerMode()
            delegate?.audioStreamerPlayModeDidChange(newValue)
        }
        get {
            return player.mode.toAudioStreamerPlayMode()
        }
    }
    
    fileprivate var playStatus: AudioStreamerPlayStatus {
        return player.state.toAudioStreamerPlayStatus()
    }
    
    fileprivate var currentAudioList: [MusicInfo]? {
        return player.items as? [MusicInfo]
    }
    
    fileprivate var currentAudio: MusicInfo? {
        return player.currentItem as? MusicInfo
    }
    
    fileprivate var duration: Double {
        return player.currentItemDuration ?? 0
    }
    
    fileprivate var currentTime: Double {
        return player.currentItemProgression ?? 0
    }
    
    fileprivate var bufferedTime: Double {
        return player.currentItemLoadedRange?.latest ?? 0
    }
    
    fileprivate func pause() {
        player.pause()
    }
    
    fileprivate func resume() {
        player.resume()
    }
    
    fileprivate func stop() {
        player.stop()
    }
    
    fileprivate func playNext() {
        player.nextOrStop()
    }
    
    fileprivate func playPrev() {
        player.previous()
    }
    
    fileprivate func seek(to time: Double) {
        player.seek(to: time)
    }
    
    fileprivate func appendAudioList(_ newList: [MusicInfo]) {
        player.add(items: newList)
    }
    
    fileprivate func removeAudioList(_ listToRemove: [MusicInfo]) {
        guard let audioList = currentAudioList else { return }
        for audio in listToRemove {
            if let index = audioList.firstIndex(where: { audio.isEqual($0) }) {
                let curIndex = currentIndex
                player.removeItem(at: index)
                if curIndex == index {
                    playNext()
                }
            }
        }
    }
    
    fileprivate func setVolume(_ newVolume: Double) {
        player.volume = Float(newVolume)
    }
}

extension AudioPlayerState {
    fileprivate func toAudioStreamerPlayStatus() -> AudioStreamerPlayStatus {
        switch self {
        case .buffering, .waitingForConnection: return .buffering
        case .playing: return .playing
        case .paused: return .pause
        case .stopped, .failed: return .stop
        }
    }
}

extension AudioPlayerMode {
    fileprivate func toAudioStreamerPlayMode() -> AudioStreamerPlayMode {
        switch self {
        case .repeat: return .singleLoop
        case .shuffle: return .random
        default: return .sequenceLoop
        }
    }
}

extension AudioStreamerPlayMode {
    fileprivate func toAudioPlayerMode() -> AudioPlayerMode {
        switch self {
        case .sequenceLoop: return .repeatAll
        case .singleLoop: return .repeat
        case .random: return .shuffle
        }
    }
}

extension AudioStreamer: AudioPlayerDelegate {
    func audioPlayer(_ audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, to state: AudioPlayerState) {
        if case let .failed(error) = state {
            delegate?.audioStreamerDidFinishWithError(error)
        } else {
            delegate?.audioStramerPlayStatusDidChange(state.toAudioStreamerPlayStatus())
        }
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, willStartPlaying item: AudioItem) {
        guard let MusicInfo = item as? MusicInfo else { return }
        delegate?.audioStreamerCurrentAudioDidChange(MusicInfo)
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didUpdateProgressionTo time: TimeInterval, percentageRead: Float) {
        delegate?.audioStreamerCurrentTimeDidChange(time)
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didLoad range: TimeRange, for item: AudioItem) {
        delegate?.audioStreamerBufferedTimeDidChange(range.latest)
    }
}

