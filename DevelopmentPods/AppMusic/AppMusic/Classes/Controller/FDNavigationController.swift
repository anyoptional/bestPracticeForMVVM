//
//  FDNavigationController.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import YYKit
import FOLDin

class FDNavigationController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if viewControllers.count > 0 {
            // 基础设置
            viewController.hidesBottomBarWhenPushed = true
            interactivePopGestureRecognizer?.delegate = nil
            
            // 全局默认返回按钮
            if viewController.prefersNavigationBarStyle == .custom {
                viewController.fd.navigationBar.contentMargin.left = 5
                let backButton = UIButton()
                backButton.setImage(UIImage(nameInBundle: "nav_back_default"), for: .normal)
                backButton.frame.size = CGSize(width: 30, height: 30)
                backButton.addTarget(self, action: #selector(popViewControllerAnimated), for: .touchUpInside)
                viewController.fd.navigationItem.leftBarButtonItem = FDBarButtonItem(customView: backButton)
            }
        }
        
        // 避免在首页疯狂左滑导致的卡死
        interactivePopGestureRecognizer?.isEnabled = (viewControllers.count > 0)
        
        super.pushViewController(viewController, animated: animated)
    }
    
}

extension FDNavigationController {
    @objc private func popViewControllerAnimated() {
        popViewController(animated: true)
    }
}

