//
//  FDPopupView+Ex.swift
//  FDUI
//
//  Created by Archer on 2019/2/25.
//

import FDNamespacer

extension FOLDin where Base: UIView {
    /// 返回弹出自身的popupView
    public var popupView: FDPopupViewProtocol? {
        return base.superview as? FDPopupView
    }
}

extension FOLDin where Base: UIViewController {
    /// 返回弹出自身的popupView
    public var popupView: FDPopupViewProtocol? {
        return base.view.fd.popupView
    }
}
