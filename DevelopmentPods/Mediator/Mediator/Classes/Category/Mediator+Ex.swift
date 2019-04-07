//
//  Mediator+Ex.swift
//  Mediator
//
//  Created by szblsx2 on 2019/3/12.
//

import UIKit

public extension Mediator {
    public static func getConversationListViewController() -> UIViewController? {
        return perform("getConversationListViewController",
                       inClass: "AppIMTarget",
                       onModule: "AppIM") as? UIViewController
    }
    
    /// 我的
    public static func getUCenterViewController() -> UIViewController? {
        return perform("getUCenterViewController",
                       inClass: "AppMineTarget",
                       onModule: "AppMine") as? UIViewController
    }
    
    /// 音乐
    public static func getAudioBoxViewController() -> UIViewController? {
        return perform("getAudioBoxViewController",
                       inClass: "AppMusicTarget",
                       onModule: "AppMusic") as? UIViewController
    }
    
    public static func getRemoteNoteViewController() -> UIViewController? {
        return perform("getRemoteNoteViewController",
                       inClass: "AppNoteTarget",
                       onModule: "AppNote") as? UIViewController
    }
    
    public static func getSportsViewController() -> UIViewController? {
        return perform("getSportsViewController",
                       inClass: "AppSportTarget",
                       onModule: "AppSport") as? UIViewController
    }
    
    /// 登录注册页
    public static func getGLarkViewController() -> UIViewController? {
        return perform("getGLarkViewController",
                       inClass: "AppLoginTarget",
                       onModule: "AppLogin") as? UIViewController
    }
    
    /// 找回密码
    public static func getRetrievePasswordViewController() -> UIViewController? {
        return perform("getRetrievePasswordViewController",
                       inClass: "AppLoginTarget",
                       onModule: "AppLogin") as? UIViewController
    }
    
    /// callback 为获取输入昵称的回调
    public static func getUpdateNicknameViewController(_ paramaters: [String : Any]) -> UIViewController? {
        return perform("getUpdateNicknameViewController:", // with parameters
                       inClass: "AppLoginTarget",
                       onModule: "AppLogin",
                       usingParameters: paramaters) as? UIViewController
    }
}
