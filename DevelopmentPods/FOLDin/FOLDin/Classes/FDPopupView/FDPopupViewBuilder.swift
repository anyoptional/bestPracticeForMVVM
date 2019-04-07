//
//  FDPopupViewBuilder.swift
//  FDPopupView
//
//  Created by Archer on 2019/2/25.
//

import Foundation

public protocol FDPopupViewProtocol {
    /// 显示
    func popup()
    /// 消失
    func dismissal()
}

/// 样式
public enum FDPopupStyle {
    /// 全透明
    case transparent
    /// 不透明
    case opaque(color: UIColor)
    /// 半透明
    case translucent(alpha: CGFloat)
    /// 模糊
    case blur(style: UIBlurEffect.Style)
}

/// 显示方式
public enum FDPopupPresentationStyle {
    /// 显示在上边
    case top
    /// 显示在左边
    case left
    /// 显示在右边
    case right
    /// 显示在下边
    case bottom
    /// 显示在中间
    case center
}

/// 动画样式
public enum FDPopupAnimation {
    /// 从上边弹出
    case fromTop
    /// 从左边弹出
    case fromLeft
    /// 从右边弹出
    case fromRight
    /// 从下边弹出
    case fromBottom
    /// 从中间弹出
    case centered
}

public class FDPopupViewBuilder {
    
    fileprivate var sourceView: UIView?
    fileprivate var contentView: UIView?
    fileprivate var contentSize: CGSize = .zero
    fileprivate var canResignOnTouch: Bool = true
    fileprivate var contentViewController: UIViewController?
    fileprivate var dismissalCompletionHandler: (() -> Void)?
    fileprivate var dismissalAimationDuration: TimeInterval = 0.25
    fileprivate var presentationAnimationDuration: TimeInterval = 0.25
    fileprivate var style: FDPopupStyle = .translucent(alpha: 0.5)
    fileprivate var dismissalAimation: FDPopupAnimation = .centered
    fileprivate var presentationAnimation: FDPopupAnimation = .centered
    fileprivate var presentationStyle: FDPopupPresentationStyle = .center
    
    public init() {}
    
    /// 设置是否允许点击空白区域消失
    public func setCanResignOnTouch(_ canResignOnTouch: Bool) -> FDPopupViewBuilder {
        self.canResignOnTouch = canResignOnTouch
        return self
    }
    
    /// 设置样式
    public func setStyle(_ style: FDPopupStyle) -> FDPopupViewBuilder {
        self.style = style
        return self
    }
    
    /// 设置从哪个view弹出
    public func setSourceView(_ sourceView: UIView?) -> FDPopupViewBuilder {
        self.sourceView = sourceView
        return self
    }
    
    /// 设置弹出的view
    public func setContentView(_ contentView: UIView?) -> FDPopupViewBuilder {
        self.contentView = contentView
        return self
    }
    
    /// 设置弹出view的大小
    public func setContentSize(_ contentSize: CGSize) -> FDPopupViewBuilder {
        self.contentSize = contentSize
        return self
    }
    
    /// 设置消失的动画
    public func setDismissalAimation(_ dismissalAimation: FDPopupAnimation) -> FDPopupViewBuilder {
        self.dismissalAimation = dismissalAimation
        return self
    }
    
    /// 设置弹出的view controller
    public func setContentViewController(_ contentViewController: UIViewController?) -> FDPopupViewBuilder {
        self.contentViewController = contentViewController
        return self
    }
    
    /// 设置消失动画的时长
    public func setDismissalAimationDuration(_ dismissalAimationDuration: TimeInterval) -> FDPopupViewBuilder {
        self.dismissalAimationDuration = dismissalAimationDuration
        return self
    }
    
    /// 设置contentView显示的位置
    public func setPresentationStyle(_ presentationStyle: FDPopupPresentationStyle) -> FDPopupViewBuilder {
        self.presentationStyle = presentationStyle
        return self
    }
    
    /// 设置显示的动画
    public func setPresentationAnimation(_ presentationAnimation: FDPopupAnimation) -> FDPopupViewBuilder {
        self.presentationAnimation = presentationAnimation
        return self
    }
    
    /// 设置消失后的回调
    public func setDismissalCompletionHandler(_ dismissalCompletionHandler: (() -> Void)?) -> FDPopupViewBuilder {
        self.dismissalCompletionHandler = dismissalCompletionHandler
        return self
    }
    
    /// 设置显示动画的时长
    public func setPresentationAimationDuration(_ presentationAnimationDuration: TimeInterval) -> FDPopupViewBuilder {
        self.presentationAnimationDuration = presentationAnimationDuration
        return self
    }
    
    public func build() -> FDPopupViewProtocol {
        let v = FDPopupView()
        v.sourceView = sourceView
        v.contentView = contentView
        v.contentSize = contentSize
        v.canResignOnTouch = canResignOnTouch
        v.dismissalAimation = dismissalAimation
        v.presentationStyle = presentationStyle
        v.contentViewController = contentViewController
        v.presentationAnimation = presentationAnimation
        v.dismissalAimationDuration = dismissalAimationDuration
        v.dismissalCompletionHandler = dismissalCompletionHandler
        v.presentationAnimationDuration = presentationAnimationDuration
        return v
    }
}
