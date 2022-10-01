//
//  Route.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/15.
//

import Foundation
import GooglePlaces

class Place:MapUserData{
    private(set) var placeId:String = ""
    private(set) var location:CLLocation? = nil
    private(set) var name: String? = nil
    private(set) var googlePlaceId: String? = nil
    private(set) var visitorCount:Int = 0
    private(set) var visitors: [PlaceVisitor] = []
    private(set) var playExp:Double = 0
    private(set) var playPoint:Int = 0
    private(set) var place:MissionPlace? = nil
    private(set) var sortType:WalkManager.Filter? = nil
    private(set) var isMark:Bool = false
    @discardableResult
    func setData(_ data:PlaceData, me:String, sortType:WalkManager.Filter?)->Place{
        self.name = data.name
        self.sortType = sortType
        self.googlePlaceId = data.googlePlaceId
        self.placeId = data.googlePlaceId ?? ""
        if let locs = data.location?.components(separatedBy: " ") {
            let latitude = locs[0].onlyNumric().toDouble()
            let longitude = locs[1].onlyNumric().toDouble()
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
        return self
    }
     
    func addMark(user:User){
        self.isMark = true
        self.visitorCount += 1
        if let userData = user.currentProfile.originData, let petData = user.pets.first?.originData {
            self.visitors.insert(PlaceVisitor(user: userData, pet:petData), at: 0)
        }
    }
    
}



