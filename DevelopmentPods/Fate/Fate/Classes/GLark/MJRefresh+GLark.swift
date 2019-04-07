//
//  MJRefresh+GLark.swift
//  Fate
//
//  Created by Archer on 2019/2/25.
//

import MJRefresh

/// 刷新控件的状态
public struct GLarkRefreshState {
    /// 上拉刷新状态
    public var upState: MJRefreshState
    /// 下拉刷新状态
    public var downState: MJRefreshState
    
    public init(_ downState: MJRefreshState = .idle, _ upState: MJRefreshState = .idle) {
        self.upState = upState
        self.downState = downState
    }
}

public extension UIScrollView {
    /// 下拉刷新控件
    public var refreshHeader: MJRefreshHeader {
        set {
            synchronized(self) {
                mj_header = newValue;
            }
        }
        get {
            return synchronized(self) {
                if let header = mj_header {
                    return header
                }
                mj_header = MJRefreshNormalHeader()
                return mj_header
            }
        }
    }
    
    /// 上拉刷新控件
    public var refreshFooter: MJRefreshFooter {
        set {
            synchronized(self) {
                mj_footer = newValue;
            }
        }
        get {
            return synchronized(self) {
                if let footer = mj_footer {
                    return footer
                }
                let footer = MJRefreshAutoStateFooter()
                footer.isOnlyRefreshPerDrag = true
                mj_footer = footer
                return mj_footer
            }
        }
    }
}

