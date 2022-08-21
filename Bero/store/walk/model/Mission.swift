//
//  Profile.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/05/19.
//

import Foundation
import SwiftUI
import UIKit

import GooglePlaces

enum MissionType:CaseIterable {
    case new, history, user
}

enum MissionLv:CaseIterable {
    case lv1, lv2, lv3, lv4
    var apiDataKey : String {
        switch self {
        case .lv1 : return "lv1"
        case .lv2 : return "lv2"
        case .lv3 : return "lv3"
        case .lv4 : return "lv4"
        }
    }
    
    static func getMissionLv(_ value:String?) -> MissionLv{
        switch value{
        case "lv1" : return .lv1
        case "lv2" : return .lv2
        case "lv3" : return .lv3
        case "lv4" : return .lv4
        default : return .lv1
        }
    }
    var info:String{
        switch self {
        case .lv1: return "Easy"
        case .lv2: return "Normal"
        case .lv3: return "Difficult"
        case .lv4: return "Very Difficult"
        }
    }
    var icon:String{
        switch self {
        case .lv1: return "ic_difficulty_easy"
        case .lv2: return "ic_difficulty_easy"
        case .lv3: return "ic_difficulty_hard"
        case .lv4: return "ic_difficulty_hard"
        }
    }
    
    var color:Color{
        switch self {
        case .lv1: return Color.brand.secondary
        case .lv2: return Color.brand.primary
        case .lv3: return Color.brand.thirdly
        case .lv4: return Color.brand.thirdly
        }
    }
    
    var point:Double{
        switch self {
        case .lv1: return 10
        case .lv2: return 20
        case .lv3: return 30
        case .lv4: return 50
        }
    }
}


extension Mission{
    static func viewSpeed(_ value:Double) -> String {
        return (value * 3600 / 1000).toTruncateDecimal(n:1) + String.app.kmPerH
    }
    static func viewDistance(_ value:Double) -> String {
        return (value / 1000).toTruncateDecimal(n:1) + String.app.km
    }
    static func viewDuration(_ value:Double) -> String {
        return value.secToMinString()
    }
}

class Mission:MapUserData{
    private (set) var missionId:Int = -1
    private (set) var type:MissionType = .new
    private (set) var lv:MissionLv = .lv1
    
    private (set) var title:String? = nil
    private (set) var description:String? = nil
    private (set) var pictureUrl:String? = nil
    private (set) var point:Int = 0
    private (set) var departure:CLLocation? = nil
    private (set) var destination:CLLocation? = nil
    private (set) var waypoints:[CLLocation] = []
    
    private (set) var distance:Double = 0 //miter
    private (set) var duration:Double = 0 //sec
    private (set) var isStart:Bool = false
    private (set) var isCompleted:Bool = false
    private (set) var playStartDate:Date? = nil
    private (set) var playTime:Double = 0
    
    private (set) var playStartDistence:Double = 0
    private (set) var playDistence:Double = 0
    
    private (set) var place:MissionPlace? = nil
    private (set) var user:User? = nil
   
    var viewDistance:String { return Self.viewDistance(self.distance) }
    var viewDuration:String { return Self.viewDuration(self.duration) }
    var viewPlayTime:String { return Self.viewDuration(self.playTime) }
    var viewPlayDistance:String { return Self.viewDistance(self.playDistence) }
    var allPoint:[CLLocation] {
        var points:[CLLocation] = []
        if let value = self.departure { points.append(value) }
        points.append(contentsOf: self.waypoints)
        if let value = self.destination { points.append(value) }
        return points
    }
    
    
    func start(location:CLLocation, walkDistence:Double) {
        self.departure = location
        self.playStartDate = AppUtil.networkTimeDate()
        self.playStartDistence = walkDistence
        self.playDistence = 0
        self.playTime = 0
        self.isStart = true
        self.isCompleted = false
    }
    func end(imgPath:String? = nil) {
        self.departure = nil
        self.playStartDate = nil
        self.playDistence = 0
        self.playTime = 0
        self.isStart = false
        if let img = imgPath {
            self.pictureUrl = img
            self.isCompleted = true
        } else {
            self.isCompleted = false
        }
    }
    
    func completed(walkDistence:Double) {
        self.playDistence = walkDistence - self.playStartDistence
        self.playTime = AppUtil.networkTimeDate().timeIntervalSince(self.playStartDate ?? Date())
        self.isCompleted = true
    }
    
    @discardableResult
    func setData(_ data:MissionData, type:MissionType)->Mission{
        self.type = type
        self.missionId = data.missionId ?? UUID().hashValue
        self.lv = MissionLv.getMissionLv(data.difficulty)
        self.title = data.title
        self.description = data.description
        self.pictureUrl = data.pictureUrl
        self.point = data.point ?? 0
        
        if let place = data.place {
            self.place = place
            if let loc = place.geometry?.location {
                self.destination = CLLocation(latitude: loc.lat ?? 0, longitude: loc.lng ?? 0)
            }
        }
        self.user = User().setData(data)
        self.distance = data.distance ?? 0
        self.duration = data.duration ?? 0
        return self
    }
    
    
}



