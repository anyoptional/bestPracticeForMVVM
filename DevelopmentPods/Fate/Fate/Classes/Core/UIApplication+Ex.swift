//
//  UIApplication+Ex.swift
//  Fate
//
//  Created by szblsx2 on 2019/3/28.
//

import FDNamespacer

extension FOLDin where Base: UIApplication {
    /// 应用名称
    public static var displayName: String? {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
    }
}
