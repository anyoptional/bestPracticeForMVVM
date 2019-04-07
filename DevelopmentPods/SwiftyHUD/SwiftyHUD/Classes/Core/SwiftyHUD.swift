//
//  SwiftyHUD.swift
//  SwiftyHUD
//
//  Created by Archer on 2019/2/25.
//

import MBProgressHUD

public struct SwiftyHUD {
    
    public static func show(message: String?,
                            duration: TimeInterval = 3,
                            textColor: UIColor = .white,
                            bezelAlpha: CGFloat = 0.6,
                            addedTo view: UIView? = UIApplication.shared.keyWindow) {
        guard let sourceView = view else { return }
        let hud = MBProgressHUD.showAdded(to: sourceView, animated: true)
        hud.isUserInteractionEnabled = false
        hud.bezelView.backgroundColor = UIColor.black.withAlphaComponent(bezelAlpha)
        hud.mode = .text
        hud.label.font = .systemFont(ofSize: 14)
        hud.label.textColor = textColor
        hud.label.numberOfLines = 0
        hud.label.text = message
        hud.margin = 8
        hud.hide(animated: true, afterDelay: duration)
    }
    
    @discardableResult
    public static func showAnimated(addedTo view: UIView? = UIApplication.shared.keyWindow,
                                    contentColor: UIColor = UIColor(white: 1, alpha: 0.7),
                                    bezelColor: UIColor = UIColor.black.withAlphaComponent(0.4),
                                    backgroundStyle: MBProgressHUDBackgroundStyle = .solidColor,
                                    backgroundColor: UIColor = UIColor(white: 1, alpha: 0.1)) -> MBProgressHUD? {
        guard let sourceView = view else { return nil }
        let hud = MBProgressHUD.showAdded(to: sourceView, animated: true)
        hud.contentColor = contentColor
        hud.bezelView.backgroundColor = bezelColor
        hud.backgroundView.style = backgroundStyle
        hud.backgroundView.color = backgroundColor
        return hud
    }
    
    public static func hideAnimated(for view: UIView? = UIApplication.shared.keyWindow) {
        guard let sourceView = view else { return }
        MBProgressHUD.hide(for: sourceView, animated: true)
    }
}
