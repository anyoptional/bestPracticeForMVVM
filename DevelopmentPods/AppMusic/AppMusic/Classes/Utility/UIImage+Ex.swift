//
//  UIImage+Ex.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import UIKit

class AppMusicBundleLoader: NSObject {}

extension Bundle {
    static let resourcesBundle: Bundle? = {
        var path = Bundle(for: AppMusicBundleLoader.self).resourcePath ?? ""
        path.append("/AppMusic.bundle")
        return Bundle(path: path)
    }()
}

extension UIImage {
    convenience init?(nameInBundle name: String) {
        self.init(named: name, in: .resourcesBundle, compatibleWith: nil)
    }
}
