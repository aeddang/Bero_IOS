//
//  LockScreenManager.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/12/28.
//

import Foundation
import ActivityKit


struct LockScreenData{
    var title:String = ""
    var info:String = ""
    var walkTime:Double = 0
    var walkDistance:Double = 0
}

@available(iOS 16.2, *)
class LockScreenManager:PageProtocol{
    private var currentActivity:Activity<BeroLockScreenAttributes>? = nil
    func startLockScreen(data:LockScreenData){
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            let state = BeroLockScreenAttributes.ContentState(walkTime: data.walkTime, walkDistance: data.walkDistance, name: data.title)
            //let attributes = BeroLockScreenAttributes(name: data.title)
            let attributes = BeroLockScreenAttributes()
            let content = ActivityContent(state: state, staleDate:nil)
            self.currentActivity = try? Activity.request(attributes: attributes, content: content)
        }
    }
    
    func updateLockScreen(data:LockScreenData){
        guard let ac = self.currentActivity else {return}
        let state = BeroLockScreenAttributes.ContentState(walkTime: data.walkTime, walkDistance: data.walkDistance, name: data.title)
        let content = ActivityContent(state: state, staleDate:nil)
        Task {
            await ac.update(content, alertConfiguration: nil)
        }
    }
    
    func alertLockScreen(data:LockScreenData){
        guard let ac = self.currentActivity else {return}
        let state = BeroLockScreenAttributes.ContentState(walkTime: data.walkTime, walkDistance: data.walkDistance, name: data.info)
        let content = ActivityContent(state: state, staleDate:nil)
        let alertConfiguration = AlertConfiguration(
            title: LocalizedStringResource(stringLiteral: data.title),
            body: LocalizedStringResource(stringLiteral: data.info),
            sound: .default)
        Task {
            await ac.update(content, alertConfiguration: alertConfiguration)
        }
    }
    
    func endLockScreen(data:LockScreenData){
        guard let ac = self.currentActivity else {return}
        let status = BeroLockScreenAttributes.ContentState(walkTime: data.walkTime, walkDistance: data.walkDistance, name: data.title)
        let content = ActivityContent(state: status, staleDate: nil)
        Task {
            await ac.end(content, dismissalPolicy: .immediate)
        }
    }
    
}
