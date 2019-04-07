//
//  APIError.swift
//  RxMoya
//
//  Created by szblsx2 on 2019/3/18.
//

import Fatal
import Foundation

enum APIError {
    /// 未知错误
    case unknown
    /// 请求超时
    case timedOut
    /// 找不到服务器
    case cannotFindHost
    /// 无法连接服务器
    case cannotConnectToHost
    /// 没有连接互联网
    case notConnectedToInternet
    /// 后台返回转json字符串出错
    case stringMapping
    /// 非HTTP成功状态码
    case statusCode(Int)
    /// 其他奇奇怪怪的错误
    case underlying(Error)
    /// 预定义的错误
    case predefined(code: Int, message: String)
}

extension APIError: ErrorConvertible {
    public var code: Int {
        switch self {
        case .unknown:
            return -10086
        case .timedOut:
            return URLError.timedOut.rawValue
        case .cannotFindHost:
            return URLError.cannotFindHost.rawValue
        case .cannotConnectToHost:
            return URLError.cannotConnectToHost.rawValue
        case .notConnectedToInternet:
            return URLError.notConnectedToInternet.rawValue
        case .stringMapping:
            return -10087
        case .statusCode(let code):
            return code
        case .underlying:
            return -10088
        case .predefined(let code, _):
            return code
        }
    }
    
    public var message: String {
        switch self {
        case .unknown:
            return "未知错误"
        case .timedOut:
            return "请求超时"
        case .cannotFindHost:
            return "找不到服务器"
        case .cannotConnectToHost:
            return "无法连接服务器"
        case .notConnectedToInternet:
            return "网络未连接"
        case .stringMapping:
            return "JSON解析错误"
        case .statusCode(let code):
            return "请求失败, code = \(code)"
        case .underlying(let error):
            return "请求失败, error = \(error)"
        case let .predefined(_, message):
            return message
        }
    }
}
