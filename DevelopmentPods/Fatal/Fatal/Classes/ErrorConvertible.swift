//
//  ErrorConvertible.swift
//  Fatal
//
//  Created by Archer on 2019/2/25.
//

import Foundation

/// 代表一个错误
public protocol ErrorConvertible: Error {
    /// 错误码
    var code: Int { get }
    /// 错误信息
    var message: String { get }
}

extension ErrorConvertible {
    /// Default implementation for `code` property
    public var code: Int {
        return 200
    }
}

fileprivate let networkErrorCodes = [URLError.timedOut.rawValue,
                                     URLError.cannotFindHost.rawValue,
                                     URLError.cannotConnectToHost.rawValue,
                                     URLError.notConnectedToInternet.rawValue]
extension ErrorConvertible {
    /// token是否过期
    public var isTokenExpired: Bool {
        return code == 40008
    }
    
    /// 是否是网络错误
    public var isFailedByNetwork: Bool {
        return networkErrorCodes.contains(code)
    }
}
