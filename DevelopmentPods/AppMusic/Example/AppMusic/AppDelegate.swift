//
//  AppDelegate.swift
//  AppMusic
//
//  Created by Archer on 03/12/2019.
//  Copyright (c) 2019 Archer. All rights reserved.
//

import Fate
import FOLDin
import Mediator
import AudioService
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupBarAppearance()
        setupKeyboardManager()
        setupRootViewController()
        
        AudioService.initialize()
        
        return true
    }

    private func setupBarAppearance() {
        let navigationBar = FDNavigationBar.appearance()
        navigationBar.barTintColor = .white
        navigationBar.shadowImage = nil
    }
    
    private func setupRootViewController() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        let tabVc = UITabBarController()
        tabVc.tabBar.isTranslucent = false
        let vc = Mediator.getAudioBoxViewController()
        tabVc.addChild(vc!)
        vc?.tabBarItem.title = "推荐"
        vc?.tabBarItem.image = UIImage(color: .red, size: CGSize(width: 18, height: 18))
        window?.rootViewController = tabVc
        window?.makeKeyAndVisible()
    }
    
    /// 配置IQkeyboardManager
    private func setupKeyboardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 30
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
    }
}
