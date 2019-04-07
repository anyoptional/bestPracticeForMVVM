//
//  MusicInfo+Ex.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import FDNamespacer
import AudioService

fileprivate var kMusicInfoIsPlayingKey: UInt8 = 0
fileprivate var kMusicInfoHighlightedKey: UInt8 = 0
extension FOLDin where Base: MusicInfo {
    /// 当前是否正在播放这首歌
    var isPlaying: Bool {
        set {
            objc_setAssociatedObject(base, &kMusicInfoIsPlayingKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return (objc_getAssociatedObject(base, &kMusicInfoIsPlayingKey) as? Bool) ?? false
        }
    }
    
    /// 用来做搜索高亮显示
    var highlightedKey: String? {
        set {
            objc_setAssociatedObject(base, &kMusicInfoHighlightedKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(base, &kMusicInfoHighlightedKey) as? String
        }
    }
}
