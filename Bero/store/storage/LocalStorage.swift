//
//  SettingStorage.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/12.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

class LocalStorage {
    struct Keys {
        static let VS = "1.000"
        static let initate = "initate" + VS
        static let retryPushToken = "retryPushToken" + VS
        
        static let loginType = "loginType" + VS
        static let loginToken = "loginToken" + VS
        static let loginId = "loginId" + VS
        
        static let authToken = "authToken" + VS
       
    }
    let defaults = UserDefaults.standard

    var retryPushToken:String{
        set(newVal){
            defaults.set(newVal, forKey: Keys.retryPushToken)
        }
        get{
            return defaults.string(forKey: Keys.retryPushToken) ?? ""
        }
    }
    
    var initate:Bool{
        set(newVal){
            defaults.set(newVal, forKey: Keys.initate)
        }
        get{
            return defaults.bool(forKey: Keys.initate) 
        }
    }
    
    var loginType:String?{
        set(newVal){
            defaults.set(newVal, forKey: Keys.loginType)
        }
        get{
            return defaults.string(forKey: Keys.loginType)
        }
    }
    var loginToken:String?{
        set(newVal){
            defaults.set(newVal, forKey: Keys.loginToken)
        }
        get{
            return defaults.string(forKey: Keys.loginToken)
        }
    }
    var loginId:String?{
        set(newVal){
            defaults.set(newVal, forKey: Keys.loginId)
        }
        get{
            return defaults.string(forKey: Keys.loginId) 
        }
    }
   
    var authToken:String?{
        set(newVal){
            defaults.set(newVal, forKey: Keys.authToken)
        }
        get{
            return defaults.string(forKey: Keys.authToken)
        }
    }
}
