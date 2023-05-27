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
    private(set) var category:PlaceApi.PlaceCategoryType? = nil
    private(set) var isMark:Bool = false
    
    
    @discardableResult
    func setData(_ data:PlaceData)->Place{
        self.title = data.name
        self.googlePlaceId = data.googlePlaceId
        self.placeId = data.placeId ?? -1
        self.category = PlaceApi.PlaceCategoryType.getType(data.placeCategory)
        if let loc = data.place?.geometry?.location {
            self.location =  CLLocation(latitude: loc.lat ?? 0, longitude: loc.lng ?? 0) 
        }
        if self.location == nil, let locs = data.location?.components(separatedBy: " ") {
            if locs.count == 2 {
                let latitude = locs[1].onlyNumric().toDouble()
                let longitude = locs[0].onlyNumric().toDouble()
                self.location = CLLocation(latitude: latitude, longitude: longitude)
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
        if let userData = user.currentProfile.originData, let petData = user.representativePet?.originData{
            self.visitors.insert(UserAndPet(user: userData, pet:petData), at: 0)
        }
    }
    
    func copySummry(origin:Place)->Place{
        self.title = String.app.place.lowercased()
        self.color = Color.brand.primary
        self.category = origin.category
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



