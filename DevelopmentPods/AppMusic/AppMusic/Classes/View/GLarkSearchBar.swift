//
//  GLarkSearchBar.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import FOLDin

/// 搜索框
class GLarkSearchBar: FDTextField {
    
    init(size: CGSize) {
        super.init(.image)
        self.size = size
        layer.cornerRadius = height / 2
        layer.masksToBounds = true
        backgroundColor = GLarkdef.gray_F2F3F7
        extendedImage = UIImage(nameInBundle: "music_search")
        leftViewInset = FDRectInsetMake(8, (height - 15) / 2, 15)
        clearButtonMode = .whileEditing
        textAreaInset = FDPositionInsetMake(10, 25)
        placeholderFont = UIFont.systemFont(ofSize: 15)
        placeholderColor = GLarkdef.gray_B1B2BF
        textColor = GLarkdef.gray_646580
        font = UIFont.systemFont(ofSize: 15)
        cursorColor = GLarkdef.blue_1687FF
        returnKeyType = .search
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
