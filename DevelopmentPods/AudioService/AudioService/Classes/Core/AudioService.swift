//
//  AudioService.swift
//  AudioService
//
//  Created by Archer on 2019/2/25.
//

import Foundation

public struct AudioService {
    /// 初始化音频服务
    /// 在didFinishLanching里调用
    public static func initialize() {
        AudioProvider.initialize()
    }
}
