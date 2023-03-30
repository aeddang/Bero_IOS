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
    case new, history, user, walk
    var apiDataKey : String {
        switch self {
        case .walk: return "Walk"
        default : return "Mission"
        }
    }
    var text : String {
        switch self {
        case .walk: return "Walk"
        default : return "Mission"
        }
    }
    var icon : String {
        switch self {
        case .walk: return Asset.icon.paw
        default : return Asset.icon.goal
        }
    }
    var completeButton : String {
        switch self {
        case .walk: return String.button.walkComplete
        default : return String.button.missionComplete
        }
    }
}



class Mission:MapUserData,ObservableObject{
    private (set) var missionId:Int = -1
    private (set) var type:MissionType = .new
    private (set) var difficulty:String? = nil
    private (set) var description:String? = nil
    private (set) var pictureUrl:String? = nil
    private (set) var point:Int = 0
    private (set) var exp:Double = 0
    private (set) var departure:CLLocation? = nil
    private (set) var waypoints:[CLLocation] = []
    private (set) var distance:Double = 0 //miter
    private (set) var duration:Double = 0 //sec
    private (set) var isStart:Bool = false
    private (set) var isCompleted:Bool = false
    private (set) var playStartDate:Date? = nil
    private (set) var playTime:Double = 0
    private (set) var playStartDistance:Double = 0
    private (set) var playDistance:Double = 0
    private (set) var walkPath:WalkPath? = nil
    private (set) var place:MissionPlace? = nil
    private (set) var userId:String? = nil
    private (set) var isFriend:Bool = false
    private (set) var user:User? = nil
    private (set) var startDate:Date? = nil
    private (set) var endDate:Date? = nil
    private(set) var completedMissions:[Int] = []
    private(set) var distanceFromMe:Double? = nil //miter
    
    var petProfile:PetProfile? = nil
    var previewImg:UIImage? = nil
    
    @Published var isExpose:Bool = false
    
    
    var viewDistance:String { return WalkManager.viewDistance(self.distance) }
    var viewDuration:String { return WalkManager.viewDuration(self.duration) }
    var viewPlayTime:String { return WalkManager.viewDuration(self.playTime) }
    var viewPlayDistance:String { return WalkManager.viewDistance(self.playDistance) }
    var viewSpeed:String {
        let d = self.distance
        let dr = self.duration/3600
        let spd = d == 0 || dr == 0 ? 0 : d/dr
        return WalkManager.viewSpeed(spd)
    }
   
    var allPoint:[CLLocation] {
        var points:[CLLocation] = []
        if let value = self.departure { points.append(value) }
        points.append(contentsOf: self.waypoints)
        if let value = self.location { points.append(value) }
        return points
    }
    
    func start(location:CLLocation, walkDistance:Double) {
        self.departure = location
        self.playStartDate = AppUtil.networkTimeDate()
        self.playStartDistance = walkDistance
        self.playDistance = 0
        self.playTime = 0
        self.isStart = true
        self.isCompleted = false
    }
    
    func end(isCompleted:Bool? = nil, imgPath:String? = nil) {
        self.departure = nil
        self.playStartDate = nil
        self.playDistance = 0
        self.playTime = 0
        self.isStart = false
        self.pictureUrl = imgPath
        if let com = isCompleted {
            self.isCompleted = com
        }
    }
    
    func completed(walkDistance:Double) {
        self.playDistance = walkDistance - self.playStartDistance
        self.playTime = AppUtil.networkTimeDate().timeIntervalSince(self.playStartDate ?? Date())
        self.isCompleted = true
    }
    @discardableResult
    func setData(_ data:User?)->Mission{
        self.user = data
        return self
    }
    @discardableResult
    func setData(_ data:WalkData, userId:String? = nil, isMe:Bool = false)->Mission{
        self.type = .walk
        self.userId = userId ?? self.userId
        self.missionId = data.walkId ?? UUID().hashValue
        //self.title = data.createdAt
        if let locs = data.locations {
            self.walkPath = WalkPath().setData(locs)
        }
        self.isExpose = self.walkPath?.picture?.isExpose ?? false
        self.pictureUrl = self.walkPath?.picture?.pictureUrl
        self.point = data.point ?? 0
        self.exp = data.exp ?? 0
        if let date = data.createdAt, let end = date.toDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss") {
            self.endDate = end
            self.startDate = end.addingTimeInterval(-(data.duration ?? 0))
        }
        if let loc = data.geos?.last {
            self.location = CLLocation(latitude: loc.lat ?? 0, longitude: loc.lng ?? 0)
        }
       
        self.isCompleted = true
        self.user = User().setData(data, isMe:isMe) 
        self.distance = data.distance ?? 0
        self.duration = data.duration ?? 0
        self.fixDestination()
        return self
    }
    
    @discardableResult
    func setData(_ data:WalkUserData)->Mission{
        self.type = .user
        self.missionId = data.walkId ?? UUID().hashValue
        self.userId = data.userId
        self.isFriend = data.isFriend ?? false
        if let pet = data.pet {
            self.petProfile = PetProfile(data: pet, userId: self.userId)
            self.petProfile?.isFriend = self.isFriend
            self.petProfile?.level = data.level
        }
        self.title = self.petProfile?.name
        self.pictureUrl = self.petProfile?.imagePath
        if let date = data.createdAt, let end = date.toDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss") {
            self.endDate = end
        }
        if let loc = data.location {
            self.location = CLLocation(latitude: loc.lat ?? 0, longitude: loc.lng ?? 0)
        }
        self.isCompleted = true
        self.fixDestination()
        return self
    }
    
    @discardableResult
    func setData(_ data:MissionData, type:MissionType)->Mission{
        self.type = type
        self.missionId = data.missionId ?? UUID().hashValue
        self.difficulty = data.difficulty
        self.title = data.title ?? String.pageText.walkMissionTitleText.replace((data.place?.name ?? "")) 
        self.description = data.description
        self.pictureUrl = data.pictureUrl
        self.point = data.point ?? 0
        self.exp = data.exp ?? 0
        if let date = data.createdAt, let end = date.toDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss") {
            self.endDate = end
            self.startDate = end.addingTimeInterval(-(data.duration ?? 0))
        }
        if let place = data.place {
            self.place = place
            if let loc = place.geometry?.location {
                self.location = CLLocation(latitude: loc.lat ?? 0, longitude: loc.lng ?? 0)
            }
        } else if let loc = data.geos?.last {
            self.location = CLLocation(latitude: loc.lat ?? 0, longitude: loc.lng ?? 0)
        }
        self.isCompleted = data.user != nil 
        self.user = User().setData(data)
        self.distance = data.distance ?? 0
        self.duration = data.duration ?? 0
        self.fixDestination()
        return self
    }
    
    private func fixDestination(){
        switch self.type {
        case .user :
            if let origin = self.location {
                let randX:Double = Double.random(in: -0.003...0.003)
                let randY:Double = Double.random(in: -0.003...0.003)
                self.location = CLLocation(latitude: origin.coordinate.latitude + randX , longitude: origin.coordinate.longitude + randY)
            }
        default : break
        }
    }
    @discardableResult
    func setDistance(_ me:CLLocation?)->Mission{
        if let me = me, let loc = self.location {
            self.distanceFromMe = me.distance(from: loc)
        }
        return self
    }
    
    @discardableResult
    func setData(_ data:WalkManager)->Mission{
        self.type = .walk
        self.title = String.app.walk
        self.missionId = data.walkId ?? -1
        self.departure = data.startLocation
        self.location = data.currentLocation
        self.distance = data.walkDistance
        self.duration = data.walkTime
        self.completedMissions = data.completedMissions
        self.point = WalkManager.getPoint(data.walkDistance)
        self.exp = WalkManager.getExp(data.walkDistance)
        self.isCompleted = true
        return self
    }
    
    func copySummry(origin:Mission)->Mission{
        self.color = Color.app.yellow
        self.title = String.app.users.lowercased()
        self.missionId = origin.missionId
        self.type = origin.type
        self.user = origin.user
        self.location = origin.location
        self.distance = origin.distance
        self.duration = origin.duration
        self.count = 1
        if let loc = origin.location {
            self.locations.append(loc)
        }
        return self
    }
}



