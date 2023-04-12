//
//  Route.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/15.
//

import Foundation
import GooglePlaces
import SwiftUI
import Lottie

class Place:MapUserData{
    private(set) var placeId:Int = -1
    private(set) var googlePlaceId: String? = nil
    private(set) var visitorCount:Int = 0
    private(set) var visitors: [UserAndPet] = []
    private(set) var playExp:Double = 0
    private(set) var playPoint:Int = 0
    private(set) var place:MissionPlace? = nil
    private(set) var sortType:WalkManager.Filter? = nil
    private(set) var isMark:Bool = false
    
    @discardableResult
    func setData(_ data:PlaceData, me:String, sortType:WalkManager.Filter?)->Place{
        self.title = data.name
        self.sortType = sortType 
        self.googlePlaceId = data.googlePlaceId
        self.placeId = data.placeId ?? -1
        if let loc = data.place?.geometry?.location {
            self.location =  CLLocation(latitude: loc.lat ?? 0, longitude: loc.lng ?? 0) 
        }
        if self.location == nil, let locs = data.location?.components(separatedBy: " ") {
            let latitude = locs[1].onlyNumric().toDouble()
            let longitude = locs[0].onlyNumric().toDouble()
            if locs.count == 2 {
                let lat = latitude
                let long = longitude
                self.location = CLLocation(latitude: lat, longitude: long)
            }
        }
        self.visitors = data.visitors ?? []
        self.visitorCount = data.visitorCnt ?? 0
        self.place = data.place ?? MissionPlace()
        self.isMark = data.isVisited ?? false
        self.playPoint = data.point ?? 0
        self.playExp = data.exp ?? 0
        return self
    }
    
    func addMark(user:User){
        self.isMark = true
        self.visitorCount += 1
        if let userData = user.currentProfile.originData, let petData = user.pets.first?.originData {
            self.visitors.insert(UserAndPet(user: userData, pet:petData), at: 0)
        }
    }
    
    func copySummry(origin:Place)->Place{
        self.title = String.app.place.lowercased()
        self.color = Color.brand.primary
        self.sortType = origin.sortType
        self.googlePlaceId = origin.googlePlaceId
        self.placeId = origin.placeId
        self.location = origin.location
        self.place = origin.place
        self.isMark = origin.isMark
        self.count = 1
        if let loc = origin.location {
            self.locations.append(loc)
        }
        return self
    }
    
    
}



