//
//  AudioPlayerError+Ex.swift
//  AudioService
//
//  Created by Archer on 2019/2/25.
//

import Fatal

extension AudioPlayerError: ErrorConvertible {
    public var message: String {
        switch self {
        case .itemNotConsideredPlayable, .noItemsConsideredPlayable:
            return "音频无法播放"
        case .maximumRetryCountHit:
            return "播放失败，请重试"
        case .foundationError(let error):
            if let urlError = error as? URLError {
                if urlError.code == URLError.timedOut {
                    return "请求超时"
                } else if urlError.code == URLError.cannotFindHost {
                    return "找不到服务器"
                } else if urlError.code == URLError.cannotConnectToHost {
                    return "无法连接服务器"
                } else if urlError.code == URLError.notConnectedToInternet {
                    return "你好像没有联网"
                }
            }
            
            let nsError = error as NSError
            if let message = nsError.userInfo["message"] as? String {
                return message
            }
            
            return "未知错误"
        }
    }
    
    public var code: Int {
        switch self {
        case .itemNotConsideredPlayable:
            return -10086
        case .noItemsConsideredPlayable:
            return -10010
        case .maximumRetryCountHit:
            return -10000
        case .foundationError:
            return -9999
        }
    }
}
