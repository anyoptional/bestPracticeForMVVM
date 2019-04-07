//
//  FDPopupView.swift
//  FDPopupView
//
//  Created by Archer on 2019/2/25.
//

import UIKit

/// Default implementation for popup view
class FDPopupView: UIControl, FDPopupViewProtocol {
    
     var style: FDPopupStyle
    
     weak var sourceView: UIView?
    
     var contentView: UIView?
    
     var contentSize: CGSize
    
     var contentViewController: UIViewController?
    
     var presentationStyle: FDPopupPresentationStyle
    
     var presentationAnimation: FDPopupAnimation
    
     var dismissalAimation: FDPopupAnimation
    
     var presentationAnimationDuration: TimeInterval
    
     var dismissalAimationDuration: TimeInterval
    
     var dismissalCompletionHandler: (() -> Void)?
    
     var canResignOnTouch: Bool
    
     init() {
        contentSize = .zero
        canResignOnTouch = true
        presentationStyle = .center
        dismissalAimation = .centered
        dismissalAimationDuration = 0.25
        style = .translucent(alpha: 0.5)
        presentationAnimation = .centered
        presentationAnimationDuration = 0.25
        super.init(frame: .zero)
        _commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("\(self) is deallocating...")
    }
}

extension FDPopupView {
     func popup() {
        let keyWindow = UIApplication.shared.keyWindow 
        guard let sourceView = (self.sourceView ?? keyWindow) else {
            debugPrint("sourceView为空")
            return
        }
        guard sourceView.size != .zero else {
            debugPrint("没有获取到sourceView的大小")
            return
        }
        guard _validate() else { return }
    
        self.frame = sourceView.bounds
        sourceView.addSubview(self)
        
        switch style {
        case .opaque(let color):
            self.backgroundColor = color
        case .transparent:
            self.backgroundColor = .clear
        case .blur(let style):
            self.backgroundColor = .clear
            let effect = UIBlurEffect(style: style)
            let blurView = UIVisualEffectView(effect: effect)
            blurView.frame = self.bounds
            self.addSubview(blurView)
        case .translucent(let alpha):
            let backgroundColor = self.backgroundColor ?? UIColor.black
            self.backgroundColor = backgroundColor.withAlphaComponent(alpha)
        }
        
        let contentView = self.contentView!
        self.addSubview(contentView)

        switch presentationAnimation {
        case .fromTop:
            contentView.centerX = self.width / 2
            contentView.top = -contentView.height
            if presentationStyle == .top {
                UIView.animate(withDuration: presentationAnimationDuration,
                               delay: 0, options: .curveEaseIn, animations: {
                                contentView.top = 0
                }, completion: nil)
            } else {
                UIView.animate(withDuration: presentationAnimationDuration,
                               delay: 0, options: .curveEaseIn, animations: {
                                contentView.centerY = self.height / 2
                }, completion: nil)
            }
        case .fromLeft:
            contentView.top = 0
            contentView.right = -contentView.width
            if presentationStyle == .left {
                UIView.animate(withDuration: presentationAnimationDuration,
                               delay: 0, options: .curveEaseIn, animations: {
                                contentView.left = 0
                }, completion: nil)
            } else {
                UIView.animate(withDuration: presentationAnimationDuration,
                               delay: 0, options: .curveEaseIn, animations: {
                                contentView.centerX = self.width / 2
                }, completion: nil)
            }
        case .fromRight:
            contentView.top = 0
            contentView.left = self.width
            if presentationStyle == .right {
                UIView.animate(withDuration: presentationAnimationDuration,
                               delay: 0, options: .curveEaseIn, animations: {
                                contentView.right = self.width
                }, completion: nil)
            } else {
                UIView.animate(withDuration: presentationAnimationDuration,
                               delay: 0, options: .curveEaseIn, animations: {
                                contentView.centerX = self.width / 2
                }, completion: nil)
            }
        case .fromBottom:
            contentView.top = self.height
            contentView.centerX = self.width / 2
            if presentationStyle == .bottom {
                UIView.animate(withDuration: presentationAnimationDuration,
                               delay: 0, options: .curveEaseIn, animations: {
                                contentView.bottom = self.height
                }, completion: nil)
            } else {
                UIView.animate(withDuration: presentationAnimationDuration,
                               delay: 0, options: .curveEaseIn, animations: {
                                contentView.centerY = self.height / 2
                }, completion: nil)
            }
        case .centered:
            if presentationStyle == .center {
                contentView.centerX = self.width / 2
                contentView.centerY = self.height / 2
                let animation = CAKeyframeAnimation(keyPath: "transform")
                animation.duration = presentationAnimationDuration
                var values = [CATransform3D]()
                values.append(CATransform3DMakeScale(0.1, 0.1, 1.0))
                values.append(CATransform3DMakeScale(1.1, 1.1, 1.0))
                values.append(CATransform3DMakeScale(0.9, 0.9, 1.0))
                values.append(CATransform3DMakeScale(1.0, 1.0, 1.0))
                animation.values = values
                contentView.layer.add(animation, forKey: "_kFDContentViewAnimationKey")
            } else {
                debugPrint("不科学的显示方式")
            }
        }
    }
    
     func dismissal() {
        guard _validate() else { return }
        let contentView = self.contentView!
        switch dismissalAimation {
        case .fromTop:
            if presentationStyle == .top || presentationStyle == .center {
                UIView.animate(withDuration: dismissalAimationDuration,
                               delay: 0, options: .curveEaseOut, animations: {
                                contentView.top = -contentView.height
                }, completion: { (flag) in
                    self._finalize()
                })
            } else {
                _fadeOut()
            }
        case .fromLeft:
            if presentationStyle == .left || presentationStyle == .center {
                UIView.animate(withDuration: dismissalAimationDuration,
                               delay: 0, options: .curveEaseOut, animations: {
                                contentView.right = -contentView.width
                }, completion: { (flag) in
                    self._finalize()
                })
            } else {
                _fadeOut()
            }
        case .fromRight:
            if presentationStyle == .right || presentationStyle == .center {
                UIView.animate(withDuration: dismissalAimationDuration,
                               delay: 0, options: .curveEaseOut, animations: {
                                contentView.left = self.width
                }, completion: { (flag) in
                    self._finalize()
                })
            } else {
                _fadeOut()
            }
        case .fromBottom:
            if presentationStyle == .bottom || presentationStyle == .center {
                UIView.animate(withDuration: dismissalAimationDuration,
                               delay: 0, options: .curveEaseOut, animations: {
                                contentView.top = self.height
                }, completion: { (flag) in
                    self._finalize()
                })
            } else {
                _fadeOut()
            }
        case .centered:
            if presentationStyle == .center {
                UIView.animate(withDuration: dismissalAimationDuration,
                               delay: 0, options: .curveEaseOut, animations: {
                                contentView.size = .zero
                                contentView.centerX = self.width / 2
                                contentView.centerY = self.height / 2
                }, completion: { (flag) in
                    self._finalize()
                })
            } else {
                _fadeOut()
            }
        }
    }
}

extension FDPopupView {
    private func _commonInit() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addTarget(self, action: #selector(_tapReceived(_:)), for: .touchUpInside)
    }
    
    private func _validate() -> Bool {
        if let contentViewController = contentViewController {
            guard contentSize != .zero else {
                debugPrint("弹出控制器时必须指定view的大小")
                return false
            }
            contentView = contentViewController.view
            contentView?.size = contentSize
        } else {
            guard let contentView = contentView else {
                debugPrint("contentView和contentViewController均为空")
                return false
            }
            if contentSize != .zero {
                debugPrint("使用设置的contentViewSize覆盖原有尺寸")
                contentView.size = contentSize
            }
            guard contentView.size != .zero else {
                debugPrint("没有设置contentView的大小")
                return false
            }
        }
        return true
    }
    
    private func _finalize() {
        self.contentView?.removeFromSuperview()
        self.removeFromSuperview()
        self.dismissalCompletionHandler?()
    }
    
    private func _fadeOut() {
        UIView.animate(withDuration: dismissalAimationDuration,
                       delay: 0, options: .curveEaseOut, animations: {
                        self.alpha = 0
        }, completion: { (flag) in
            self._finalize()
        })
    }
}

extension FDPopupView {
    @objc private func _tapReceived(_ sender: UIControl) {
        if canResignOnTouch {
            dismissal()
        }
    }
}
