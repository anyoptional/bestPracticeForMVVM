//
//  AppDelegate.swift
//  MVVMPractice
//
//  Created by Archer on 2019/4/5.
//  Copyright © 2019 Archer. All rights reserved.
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
        
        setupAudioService()
        setupBarAppearance()
        setupKeyboardManager()
        setupRootViewController()

        return true
    }
    
    private func setupAudioService() {
        AudioService.initialize()
    }
    
    private func setupBarAppearance() {
        let navigationBar = FDNavigationBar.appearance()
        navigationBar.barTintColor = .white
        navigationBar.shadowImage = nil
    }
    
    private func setupRootViewController() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.rootViewController = Mediator.getAudioBoxViewController()!
        window?.makeKeyAndVisible()
    }
    
    private func setupKeyboardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 30
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
    }
}
