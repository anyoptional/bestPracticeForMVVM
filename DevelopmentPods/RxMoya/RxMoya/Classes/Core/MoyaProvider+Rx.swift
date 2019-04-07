//
//  MoyaProvider+Rx.swift
//  RxMoya
//
//  Created by Archer on 2018/11/19.
//

import Moya
import RxSwift
import SwiftyJSON

/// Extends reactive proxy
extension MoyaProvider: ReactiveCompatible {}

/// Reactive extension for MoyaProvider
public extension Reactive where Base: Moya.MoyaProvider<Moya.MultiTarget> {
    /// Sends a HTTP request.
    ///
    /// - Parameters:
    ///   - token: The token for request.
    ///   - allowsURLCache: Allows cache respose or not.
    ///   - ignoredKeys: The ignorable keys in parameters.
    /// - Returns: Observable sequence that contains response json
    public func request(_ token: APITargetType, allowsURLCache: Bool = false, ignoredKeys: [String] = []) -> Observable<JSONObject> {
        return Observable.create { [weak base = base] observer in
            /// load cache first
            if allowsURLCache {
                if let jsonObject = Cache.objectForTarget(token, ignoredKeys: ignoredKeys) {
                    observer.onNext(jsonObject)
                    // Do not call onCompleted here, we need to refresh cache
                }
            }
            /// send request
            let cancellableToken = base?.request(Base.Target(token), callbackQueue: nil, progress: nil) { result in
                result.analysis(ifSuccess: { (response) in
                    do {
                        let response = try response.filterSuccessfulStatusCodes()
                        let jsonObject = try response.mapString()
                        /// store in cache
                        if allowsURLCache { Cache.setObject(jsonObject, forTarget: token, ignoredKeys: ignoredKeys) }
                        /////////////////////////////////////////////////////////////////////////////////////////////
                        /// NOTE: 业务相关的错误处理
                        /////////////////////////////////////////////////////////////////////////////////////////////
                        let json = JSON(parseJSON: jsonObject)
                        if let data = json.dictionary {
                            if let errorCode = data["error_code"]?.int,
                                errorCode != 22000  {
                                observer.onError(APIError.predefined(code: errorCode, message: "百度后台错误"))
                            } else {
                                /// emit element
                                observer.onNext(jsonObject)
                                /// unsubscribe
                                observer.onCompleted()
                            }
                        } else {
                            observer.onError(APIError.stringMapping)
                        }
                    } catch MoyaError.statusCode(let response) {
                        observer.onError(APIError.statusCode(response.statusCode))
                    } catch MoyaError.stringMapping {
                        observer.onError(APIError.stringMapping)
                    } catch {
                        /// possibly unreachable, all error has catached above
                        debugPrint("UnknownError = ", error)
                        observer.onError(APIError.unknown)
                    }
                }, ifFailure: { (error) in
                    if case let .underlying(error, _) = error,
                        let urlError = error as? URLError {
                        if urlError.code == URLError.timedOut {
                            observer.onError(APIError.timedOut)
                        } else if urlError.code == URLError.cannotFindHost {
                            observer.onError(APIError.cannotFindHost)
                        } else if urlError.code == URLError.cannotConnectToHost {
                            observer.onError(APIError.cannotConnectToHost)
                        } else if urlError.code == URLError.notConnectedToInternet {
                            observer.onError(APIError.notConnectedToInternet)
                        } else {
                            observer.onError(APIError.underlying(urlError))
                        }
                    } else {
                        debugPrint("MoyaError = ", error)
                        observer.onError(APIError.underlying(error))
                    }
                })
            }
            return Disposables.create { cancellableToken?.cancel() }
        }.observeOn(MainScheduler.instance)
        /// ignore when cache is same as network response
        .distinctUntilChanged()
        /// shares resources
        .share()
    }
}
