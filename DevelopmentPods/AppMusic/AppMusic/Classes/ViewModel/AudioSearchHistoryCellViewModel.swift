//
//  AudioSearchHistoryCellViewModel.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import YYKit
import RxSwift
import AudioService

protocol AudioSearchHistoryCellViewModelInputs {
    func configure(value: [String])
}

protocol AudioSearchHistoryCellViewModelOutputs {
    var attributedText: NSAttributedString? { get }
}

protocol AudioSearchHistoryCellViewModelType {
    var inputs: AudioSearchHistoryCellViewModelInputs { get }
    var outputs: AudioSearchHistoryCellViewModelOutputs { get }
}

class AudioSearchHistoryCellViewModel: AudioSearchHistoryCellViewModelType
    , AudioSearchHistoryCellViewModelInputs
    , AudioSearchHistoryCellViewModelOutputs {
    
    func configure(value: [String]) {
        let keywords = value
        var height: CGFloat = 0
        let attrText = NSMutableAttributedString()
        for (index, keyword) in keywords.enumerated() {
            let keywordText = NSMutableAttributedString(string: keyword)
            keywordText.insertString("    ", at: 0)
            keywordText.appendString("    ")
            keywordText.color = GLarkdef.gray_646580
            keywordText.font = UIFont.systemFont(ofSize: 14)
            keywordText.setTextBinding(YYTextBinding(deleteConfirm: false), range: (keywordText.string as NSString).rangeOfAll())
            let border = YYTextBorder(fill: GLarkdef.gray_F2F3F7, cornerRadius: 50)
            border.insets = UIEdgeInsets(top: -6, left: -10, bottom: -6, right: -10)
            border.lineJoin = .bevel
            keywordText.setTextBackgroundBorder(border, range: (keywordText.string as NSString).range(of: keyword))
            keywordText.setTextHighlight((keywordText.string as NSString).rangeOfAll(), color: nil, backgroundColor: nil, userInfo: nil)
            attrText.append(keywordText)
            attrText.lineSpacing = 24
            attrText.lineBreakMode = .byWordWrapping
            
            let keywordContainer = YYTextContainer()
            keywordContainer.size = CGSize(width: kScreenWidth - 18, height: CGFloat.greatestFiniteMagnitude)
            let keywordLayout = YYTextLayout(container: keywordContainer, text: attrText)
            if (keywordLayout?.textBoundingSize.height ?? 0) > height {
                if index != 0 {
                    attrText.insertString("\n", at: UInt(attrText.length - keywordText.length))
                }
                height = keywordLayout?.textBoundingSize.height ?? 0
            }
        }
        
        attributedText = attrText.fd.copy()
    }
    
    var inputs: AudioSearchHistoryCellViewModelInputs {
        return self
    }
    
    var outputs: AudioSearchHistoryCellViewModelOutputs {
        return self
    }
    
    var attributedText: NSAttributedString?
}
