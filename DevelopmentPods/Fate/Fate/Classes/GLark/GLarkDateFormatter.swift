//
//  GLarkDateFormatter.swift
//  Fate
//
//  Created by Archer on 2019/2/25.
//

import Foundation

public struct GLarkDateFormatter {
    /// yyyy年MM月dd日
    public static let `default`: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy年MM月dd日"
        return f
    }()
    
    /// yyyy-MM-dd
    public static let standard: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    /// yyyy-MM-dd HH:mm
    public static let complete: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        return f
    }()
    
    /// yyyy-MM-dd HH:mm:ss
    public static let full: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }()
}
