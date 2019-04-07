//
//  AppMusicTarget.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Foundation

@objcMembers
class AppMusicTarget: NSObject {
    /// 获取音乐列表
    func getAudioBoxViewController() -> UIViewController {
        return FDNavigationController(rootViewController: AudioBoxViewController())
    }
}
