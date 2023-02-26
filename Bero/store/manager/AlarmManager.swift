//
//  AlramManager.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/30.
//

import Foundation
import SwiftUI

struct AlramData{
    var title:String? = nil
    var text:String? = nil
}

struct AlarmManager {
    static func sendWalkEvent(_ evt:WalkEvent){
        guard let title  = evt.pushTitle else {return}
        Self.sendLocalPush(data: .init(title: title, text: evt.pushText),
                           movePage: IwillGo(with: PageProvider.getPageObject(.walk)).stringfy())
    }
    static func sendLocalPush(data:AlramData, movePage:String? = nil){
        let push = UNMutableNotificationContent()
        push.title = data.title ?? ""
        //push.subtitle = data.text ?? ""
        push.body = data.text ?? ""
        push.badge = nil
        var userInfo = [String:Any]()
        var aps = [String:Any]()
        
        var system_data = [String:Any]()
        system_data["messageId"] = UUID().uuidString
        system_data["type"] = "message"
        aps["mutable-content"] = 1
        aps["alert"] = data.title
        userInfo["aps"] = aps
        if let movePage = movePage {
            userInfo["page"] = movePage
        }
        push.userInfo = userInfo
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: push.copy() as! UNNotificationContent , trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
