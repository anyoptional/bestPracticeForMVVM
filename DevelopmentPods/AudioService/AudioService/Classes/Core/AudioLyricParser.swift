//
//  AudioLyricParser.swift
//  AudioService
//
//  Created by Archer on 2019/3/17.
//

import RxSwift

/// 代表一句歌词
public protocol AudioLyricItemProtocol {
    /// 当前时间
    var curTime: String? { get }
    /// 歌词内容
    var contents: String? { get }
    /// 秒数
    var seconds: Double { get }
    /// 毫秒
    var millisconds: Double { get }
}

/// 代表一个解析器
public protocol AudioLyricParserProtocol {
    /// 歌词地址
    var lyricURL: URL? { get set }
    /// 是否忽略空白歌词
    var ignoreBlankLyrics: Bool { get set }
    /// 解析歌词
    func parse() -> Observable<[AudioLyricItemProtocol]?>
}

/// 解析器构造
public class AudioLyricParserBuilder {
    
    fileprivate var lyricURL: URL?
    fileprivate var ignoreBlankLyrics = true
    
    public init() {}
    
    public func setLyricURL(_ lyricURL: URL?) -> AudioLyricParserBuilder {
        self.lyricURL = lyricURL
        return self
    }
    
    public func setIgnoreBlankLyrics(_ ignoreBlankLyrics: Bool) -> AudioLyricParserBuilder {
        self.ignoreBlankLyrics = ignoreBlankLyrics
        return self
    }
    
    public func build() -> AudioLyricParserProtocol {
        var parser = AudioLyricParser()
        parser.lyricURL = lyricURL
        parser.ignoreBlankLyrics = ignoreBlankLyrics
        return parser
    }
}

// MARK: 具体实现类

fileprivate struct AudioLyricItem: AudioLyricItemProtocol {
    fileprivate var curTime: String?
    fileprivate var contents: String?
    fileprivate var seconds: Double = 0.0
    fileprivate var millisconds: Double = 0.0
}

extension AudioLyricItem: CustomStringConvertible {
    var description: String {
        let time = curTime ?? "无法获取时间"
        let lyric = contents ?? "找不到歌词"
        return "curTime = \(time), contents = \(lyric)"
    }
}

fileprivate struct AudioLyricParser: AudioLyricParserProtocol {
    
    fileprivate var lyricURL: URL?
    fileprivate var ignoreBlankLyrics = true
    
    /// 解析歌词
    fileprivate func parse() -> Observable<[AudioLyricItemProtocol]?> {
        return fetchLyric()
            .map { (fullLyric) in
                // 匹配时间
                let partten = "\\[[0-9][0-9]:[0-9][0-9].[0-9]{1,}\\]"
                guard let regex = try? NSRegularExpression(pattern: partten,
                                                           options: .caseInsensitive) else { return nil}
                // 获取每句歌词
                let allLyrics = fullLyric.components(separatedBy: "\n")
                var items = [AudioLyricItem]()
                for lyric in allLyrics {
                    // 开始匹配
                    let allMataches = regex.matches(in: lyric, options: .reportProgress,
                                                    range: lyric.rangeOfAll())
                    // 获取歌词
                    let contents = lyric.components(separatedBy: "]").last
                    // 是否过滤空白歌词
                    if self.ignoreBlankLyrics && (contents == nil || contents!.isBlank) {
                        continue
                    }
                    // 遍历结果
                    for match in allMataches {
                        var time = lyric.substring(with: match.range)
                        // 去掉"["和"]" 得到00:00.00格式的时间
                        time = String(time.dropFirst().dropLast())
                        let minute = time.substring(with: NSMakeRange(0, 2))
                        let second = time.substring(with: NSMakeRange(3, 2))
                        let milliscond = time.substring(from: 6)
                        // 全部转成毫秒
                        let totalTimeInterval = minute.toDouble() * 60 * 1000 + second.toDouble() * 1000 + milliscond.toDouble()
                        // 构建lyric item
                        var item = AudioLyricItem()
                        item.contents = contents
                        item.millisconds = totalTimeInterval
                        item.seconds = totalTimeInterval / 1000
                        item.curTime = time.substring(to: 5)
                        items.append(item)
                    }
                }
                // 按时间升序排列
                return items.sorted(by: { $0.millisconds < $1.millisconds })
        }.observeOn(MainScheduler.instance)
    }
    
    fileprivate func fetchLyric() -> Observable<String> {
        guard let url = lyricURL else { return .empty() }
        return Observable.create({ (observer) -> Disposable in
            let task = URLSession.shared.dataTask(with: url) { (data, _, _) in
                if let data = data, let lyric = String(data: data, encoding: .utf8) {
                    observer.onNext(lyric)
                    observer.onCompleted()
                } else {
                    let error = NSError(domain: "com.archer.error.domain",
                                        code: -77777, userInfo: ["message" : "找不到歌词"])
                    observer.onError(AudioPlayerError.foundationError(error))
                }
            }
            task.resume()
            return Disposables.create { task.cancel() }
        })
    }
}

extension String {
    fileprivate var length: Int {
        return (self as NSString).length
    }
    
    fileprivate var isBlank: Bool {
        return isEmpty ||
            trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
    }
    
    fileprivate func toDouble() -> Double {
        return Double(self) ?? 0.0
    }
    
    fileprivate func rangeOfAll() -> NSRange {
        return NSMakeRange(0, length)
    }
    
    fileprivate func substring(with range: NSRange) -> String {
        return (self as NSString).substring(with: range)
    }
    
    fileprivate func substring(from: Int) -> String {
        return (self as NSString).substring(from: from)
    }
    
    fileprivate func substring(to: Int) -> String {
        return (self as NSString).substring(to: to)
    }
}

